<?php

use App\Modules\Admin\Controllers\UserManagementController;
use App\Modules\Auth\Controllers\AuthController;
use App\Modules\Contacts\Controllers\ContactController;
use App\Modules\Ocr\Controllers\OcrController;
use App\Modules\Packages\Controllers\PackageController;
use App\Modules\Routes\Controllers\RouteController;
use App\Modules\Trips\Controllers\TripController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Health check endpoint for Docker
Route::get('health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toIso8601String(),
    ]);
});

Route::prefix('v1')->group(function () {
    // Auth routes (public) - rate limited to prevent brute force
    Route::prefix('auth')->middleware('throttle:5,1')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('google', [AuthController::class, 'googleLogin']);
    });

    // Protected routes - Solo autenticación (sin verificar driver status)
    Route::middleware('auth:sanctum')->group(function () {
        // Auth
        Route::prefix('auth')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);
            Route::post('select-user-type', [AuthController::class, 'selectUserType']);
        });

        // Profile
        Route::prefix('profile')->group(function () {
            Route::put('/', [AuthController::class, 'updateProfile']);
            Route::put('password', [AuthController::class, 'updatePassword']);
            Route::put('fcm-token', [AuthController::class, 'updateFcmToken']);
            Route::post('avatar', [AuthController::class, 'uploadAvatar']);
        });
    });

    // Protected routes - Requiere driver aprobado O ser client/super_admin
    Route::middleware(['auth:sanctum', 'user.driver_approved'])->group(function () {
        // Packages - Todos pueden acceder (filtrado en controller y policy)
        Route::prefix('packages')->group(function () {
            Route::get('/', [PackageController::class, 'index']);
            Route::get('my-orders', [PackageController::class, 'myOrders']);
            Route::post('/', [PackageController::class, 'store']);
            Route::get('counts', [PackageController::class, 'counts']);
            Route::get('client-stats', [PackageController::class, 'clientStats']);
            Route::post('bulk-status', [PackageController::class, 'bulkUpdateStatus']);
            Route::get('{package}', [PackageController::class, 'show']);
            Route::put('{package}', [PackageController::class, 'update']);
            Route::delete('{package}', [PackageController::class, 'destroy']);
            Route::patch('{package}/status', [PackageController::class, 'updateStatus']);
            Route::get('{package}/history', [PackageController::class, 'history']);
            Route::post('{package}/images', [PackageController::class, 'addImages']);
            Route::delete('{package}/images/{media}', [PackageController::class, 'deleteImage']);
        });

        // Routes - Solo drivers y super_admin (policy valida)
        Route::prefix('routes')->group(function () {
            Route::get('/', [RouteController::class, 'index']);
            Route::post('/', [RouteController::class, 'store']);
            Route::get('{route}', [RouteController::class, 'show']);
            Route::put('{route}', [RouteController::class, 'update']);
            Route::delete('{route}', [RouteController::class, 'destroy']);
            Route::get('{route}/trips', [RouteController::class, 'trips']);
            Route::post('{route}/trips', [RouteController::class, 'createTrip']);
        });

        // Trips - Solo drivers y super_admin (policy valida)
        Route::prefix('trips')->group(function () {
            Route::get('/', [TripController::class, 'index']);
            Route::post('/', [TripController::class, 'store']);
            Route::get('{trip}', [TripController::class, 'show']);
            Route::put('{trip}', [TripController::class, 'update']);
            Route::delete('{trip}', [TripController::class, 'destroy']);
            Route::patch('{trip}/status', [TripController::class, 'updateStatus']);
            Route::get('{trip}/packages', [TripController::class, 'packages']);
            Route::post('{trip}/packages', [TripController::class, 'assignPackages']);
        });

        // Contacts - Solo drivers y super_admin (policy valida)
        Route::prefix('contacts')->group(function () {
            Route::get('/', [ContactController::class, 'index']);
            Route::get('search', [ContactController::class, 'search']);
            Route::post('/', [ContactController::class, 'store']);
            Route::get('{contact}', [ContactController::class, 'show']);
            Route::put('{contact}', [ContactController::class, 'update']);
            Route::delete('{contact}', [ContactController::class, 'destroy']);
            Route::get('{contact}/packages', [ContactController::class, 'packages']);
        });

        // OCR - Solo drivers y super_admin
        Route::post('ocr/scan', [OcrController::class, 'scan']);
    });

    // Admin routes - Solo super_admin
    Route::middleware(['auth:sanctum', 'role:super_admin'])->prefix('admin')->group(function () {
        Route::get('users', [UserManagementController::class, 'allUsers']);
        Route::get('drivers/pending', [UserManagementController::class, 'pendingDrivers']);
        Route::post('drivers/{user}/approve', [UserManagementController::class, 'approveDriver']);
        Route::post('drivers/{user}/reject', [UserManagementController::class, 'rejectDriver']);
    });
});
