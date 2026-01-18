<?php

use App\Modules\Auth\Controllers\AuthController;
use App\Modules\Ocr\Controllers\OcrController;
use App\Modules\Packages\Controllers\PackageController;
use App\Modules\Routes\Controllers\RouteController;
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

    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        // Auth
        Route::prefix('auth')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);
        });

        // Profile
        Route::prefix('profile')->group(function () {
            Route::put('/', [AuthController::class, 'updateProfile']);
            Route::put('password', [AuthController::class, 'updatePassword']);
            Route::put('fcm-token', [AuthController::class, 'updateFcmToken']);
            Route::post('avatar', [AuthController::class, 'uploadAvatar']);
        });

        // Packages
        Route::prefix('packages')->group(function () {
            Route::get('/', [PackageController::class, 'index']);
            Route::post('/', [PackageController::class, 'store']);
            Route::post('bulk-status', [PackageController::class, 'bulkUpdateStatus']);
            Route::get('{package}', [PackageController::class, 'show']);
            Route::put('{package}', [PackageController::class, 'update']);
            Route::delete('{package}', [PackageController::class, 'destroy']);
            Route::patch('{package}/status', [PackageController::class, 'updateStatus']);
            Route::get('{package}/history', [PackageController::class, 'history']);
            Route::post('{package}/images', [PackageController::class, 'addImages']);
            Route::delete('{package}/images/{media}', [PackageController::class, 'deleteImage']);
        });

        // Routes
        Route::prefix('routes')->group(function () {
            Route::get('/', [RouteController::class, 'index']);
            Route::post('/', [RouteController::class, 'store']);
            Route::get('{route}', [RouteController::class, 'show']);
            Route::put('{route}', [RouteController::class, 'update']);
            Route::delete('{route}', [RouteController::class, 'destroy']);
            Route::patch('{route}/status', [RouteController::class, 'updateStatus']);
            Route::get('{route}/packages', [RouteController::class, 'packages']);
            Route::post('{route}/packages', [RouteController::class, 'assignPackages']);
        });

        // OCR
        Route::post('ocr/scan', [OcrController::class, 'scan']);
    });
});
