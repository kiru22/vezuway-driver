<?php

namespace App\Modules\Auth\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Modules\Auth\Requests\UpdateAvatarRequest;
use App\Modules\Auth\Resources\UserResource;
use Google\Client as GoogleClient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
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

        // Log para diagnóstico de Google OAuth
        Log::warning('Google login attempt', [
            'has_id_token' => !empty($validated['id_token']),
            'has_access_token' => !empty($validated['access_token']),
            'id_token_preview' => !empty($validated['id_token']) ? substr($validated['id_token'], 0, 50) . '...' : null,
            'access_token_preview' => !empty($validated['access_token']) ? substr($validated['access_token'], 0, 20) . '...' : null,
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
            }

            $token = $user->createToken('auth-token')->plainTextToken;

            return response()->json([
                'user' => new UserResource($user),
                'token' => $token,
            ]);
        } catch (\Exception $e) {
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

        // Log de client IDs configurados
        Log::warning('Verifying id_token', [
            'valid_client_ids' => $validClientIds,
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
                    Log::warning('Token verified successfully', [
                        'client_id' => $clientId,
                        'aud' => $payload['aud'] ?? 'unknown',
                    ]);
                    return $payload;
                }
            } catch (\Exception $e) {
                Log::warning('Token verification failed for client_id', [
                    'client_id' => $clientId,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        Log::warning('All token verifications failed');
        return null;
    }

    private function verifyAccessToken(string $accessToken): ?array
    {
        try {
            Log::warning('Verifying access_token via Google userinfo API');

            $response = Http::timeout(10)
                ->withToken($accessToken)
                ->get('https://www.googleapis.com/oauth2/v3/userinfo');

            Log::warning('Google userinfo API response', [
                'status' => $response->status(),
                'successful' => $response->successful(),
            ]);

            if ($response->failed()) {
                Log::warning('Google userinfo API request failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                return null;
            }

            $userInfo = $response->json();

            Log::warning('Google userinfo response data', [
                'has_email' => !empty($userInfo['email']),
                'email_verified' => $userInfo['email_verified'] ?? 'not_present',
                'email_verified_type' => gettype($userInfo['email_verified'] ?? null),
            ]);

            if (empty($userInfo['email'])) {
                Log::warning('Google userinfo missing email');
                return null;
            }

            // Security: Verify email is verified to prevent account takeover
            if (empty($userInfo['email_verified']) || $userInfo['email_verified'] !== true) {
                Log::warning('Google login rejected: email not verified', [
                    'email' => $userInfo['email'] ?? 'unknown',
                    'email_verified_value' => $userInfo['email_verified'] ?? 'not_present',
                ]);

                return null;
            }

            Log::warning('Access token verified successfully', [
                'email' => $userInfo['email'],
            ]);

            return $userInfo;
        } catch (\Exception $e) {
            Log::error('Google access token verification failed', [
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }
}
