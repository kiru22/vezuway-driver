<?php

namespace App\Modules\Notifications;

use App\Modules\Notifications\Services\NotificationService;
use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Contract\Messaging;

class NotificationServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(NotificationService::class, function ($app) {
            return new NotificationService(
                $app->make(Messaging::class)
            );
        });
    }

    public function boot(): void
    {
        //
    }
}
