<?php

namespace App\Modules\Auth\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Modules\Auth\Requests\UpdateAvatarRequest;
use App\Modules\Auth\Resources\UserResource;
use App\Modules\Contacts\Services\ContactService;
use App\Shared\Enums\DriverStatus;
use Google\Client as GoogleClient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(private readonly ContactService $contactService) {}

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:50',
            'locale' => 'nullable|string|in:es,uk,en',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'] ?? null,
            'locale' => $validated['locale'] ?? 'es',
        ]);

        // Vincular contacto existente si hay uno con este email
        $this->contactService->linkContactToUser($validated['email'], $user->id);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Las credenciales proporcionadas son incorrectas.'],
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Sesión cerrada correctamente']);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json(new UserResource($request->user()));
    }

    public function selectUserType(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_type' => 'required|string|in:client,driver',
        ]);

        $user = $request->user();

        // Verificar que el usuario NO tiene rol asignado (solo primera vez)
        if ($user->roles()->count() > 0) {
            return response()->json([
                'message' => 'Ya tienes un tipo de cuenta asignado',
            ], 403);
        }

        $user->assignRole($validated['user_type']);

        if ($validated['user_type'] === 'driver') {
            $user->update(['driver_status' => DriverStatus::PENDING]);
        }

        // Limpiar cache de permisos
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        return response()->json(new UserResource($user->fresh()));
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'nullable|string|max:50',
            'locale' => 'sometimes|string|in:es,uk,en',
            'theme_preference' => 'sometimes|string|in:light,dark,system',
        ]);

        $request->user()->update($validated);

        return response()->json(new UserResource($request->user()));
    }

    public function updateFcmToken(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $request->user()->update(['fcm_token' => $validated['fcm_token']]);

        return response()->json(['message' => 'FCM token actualizado']);
    }

    public function updatePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_password' => 'required',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (! Hash::check($validated['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['La contraseña actual es incorrecta.'],
            ]);
        }

        $user->update(['password' => Hash::make($validated['password'])]);

        return response()->json(['message' => 'Contraseña actualizada correctamente']);
    }

    public function uploadAvatar(UpdateAvatarRequest $request): JsonResponse
    {
        $user = $request->user();

        $user->clearMediaCollection('avatar');
        $user->addMediaFromRequest('avatar')->toMediaCollection('avatar');

        $avatarUrl = $user->getFirstMediaUrl('avatar', 'thumb');
        $user->update(['avatar_url' => $avatarUrl]);

        return response()->json(new UserResource($user->fresh()));
    }

    public function googleLogin(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'id_token' => 'nullable|string',
            'access_token' => 'nullable|string',
        ]);

        if (empty($validated['id_token']) && empty($validated['access_token'])) {
            return response()->json([
                'message' => 'Se requiere id_token o access_token',
            ], 422);
        }

        try {
            $googleId = null;
            $email = null;
            $name = null;
            $avatarUrl = null;

            if (! empty($validated['id_token'])) {
                // Verify ID token (preferred method for mobile)
                $payload = $this->verifyIdToken($validated['id_token']);
                if (! $payload) {
                    return response()->json([
                        'message' => 'Token de Google inválido',
                    ], 401);
                }

                // Security: Verify email is verified to prevent account takeover
                if (empty($payload['email_verified']) || $payload['email_verified'] !== true) {
                    Log::warning('Google login rejected: email not verified (id_token)', [
                        'email' => $payload['email'] ?? 'unknown',
                    ]);

                    return response()->json([
                        'message' => 'El email de Google no está verificado',
                    ], 401);
                }

                $googleId = $payload['sub'];
                $email = $payload['email'];
                $name = $payload['name'] ?? $payload['email'];
                $avatarUrl = $payload['picture'] ?? null;
            } else {
                // Verify access token via Google's userinfo API (fallback for web)
                $userInfo = $this->verifyAccessToken($validated['access_token']);
                if (! $userInfo) {
                    return response()->json([
                        'message' => 'Token de Google inválido',
                    ], 401);
                }

                $googleId = $userInfo['sub'] ?? $userInfo['id'];
                $email = $userInfo['email'];
                $name = $userInfo['name'] ?? $userInfo['email'];
                $avatarUrl = $userInfo['picture'] ?? null;
            }

            // Find user by google_id or email
            $user = User::where('google_id', $googleId)
                ->orWhere('email', $email)
                ->first();

            if ($user) {
                // Link Google account if not already linked
                if (! $user->google_id) {
                    $user->update([
                        'google_id' => $googleId,
                        'avatar_url' => $avatarUrl ?? $user->avatar_url,
                    ]);
                }
            } else {
                // Create new user
                $user = User::create([
                    'name' => $name,
                    'email' => $email,
                    'google_id' => $googleId,
                    'avatar_url' => $avatarUrl,
                    'password' => null, // OAuth users don't have password
                    'locale' => 'es',
                ]);

                // Vincular contacto existente si hay uno con este email
                $this->contactService->linkContactToUser($email, $user->id);
            }

            $token = $user->createToken('auth-token')->plainTextToken;

            return response()->json([
                'user' => new UserResource($user),
                'token' => $token,
            ]);
        } catch (\Exception $e) {
            Log::error('Google login exception', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'message' => 'Error al autenticar con Google',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 401);
        }
    }

    private function verifyIdToken(string $idToken): ?array
    {
        $validClientIds = array_filter([
            config('services.google.client_id'),
            config('services.google.client_id_ios'),
            config('services.google.client_id_android'),
        ]);

        if (empty($validClientIds)) {
            Log::warning('Google authentication not configured: no client IDs found in services.google config');

            return null;
        }

        $client = new GoogleClient;

        foreach ($validClientIds as $clientId) {
            $client->setClientId($clientId);
            try {
                $payload = $client->verifyIdToken($idToken);
                if ($payload) {
                    return $payload;
                }
            } catch (\Exception $e) {
                Log::debug('Token verification failed for client_id', [
                    'client_id' => $clientId,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return null;
    }

    private function verifyAccessToken(string $accessToken): ?array
    {
        try {
            $response = Http::timeout(10)
                ->withToken($accessToken)
                ->get('https://www.googleapis.com/oauth2/v3/userinfo');

            if ($response->failed()) {
                Log::debug('Google userinfo API request failed', [
                    'status' => $response->status(),
                ]);

                return null;
            }

            $userInfo = $response->json();

            if (empty($userInfo['email'])) {
                return null;
            }

            if (empty($userInfo['email_verified']) || $userInfo['email_verified'] !== true) {
                Log::warning('Google login rejected: email not verified', [
                    'email' => $userInfo['email'],
                ]);

                return null;
            }

            return $userInfo;
        } catch (\Exception $e) {
            Log::error('Google access token verification failed', [
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }
}
