<?php

namespace App\Modules\Admin\Services;

use App\Models\User;
use App\Modules\Admin\Mail\DriverApprovedMail;
use App\Modules\Admin\Mail\DriverRejectedMail;
use App\Shared\Enums\DriverStatus;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Laravel\Firebase\Facades\Firebase;

class UserManagementService
{
    public function approveDriver(User $driver): void
    {
        $driver->update(['driver_status' => DriverStatus::APPROVED]);

        $this->sendApprovalNotification($driver);
    }

    public function rejectDriver(User $driver, ?string $reason): void
    {
        $driver->update(['driver_status' => DriverStatus::REJECTED]);

        $this->sendRejectionNotification($driver, $reason);
    }

    private function sendApprovalNotification(User $driver): void
    {
        // Email
        Mail::to($driver->email)->send(new DriverApprovedMail($driver));

        // Push notification (si tiene FCM token)
        if ($driver->fcm_token) {
            try {
                $messaging = Firebase::messaging();
                $message = CloudMessage::withTarget('token', $driver->fcm_token)
                    ->withNotification(
                        Notification::create('¡Cuenta aprobada!', 'Ya puedes empezar a usar vezuway como conductor')
                    );

                $messaging->send($message);
            } catch (\Exception $e) {
                Log::error('Failed to send FCM notification for driver approval', [
                    'driver_id' => $driver->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }
    }

    private function sendRejectionNotification(User $driver, ?string $reason): void
    {
        // Email
        Mail::to($driver->email)->send(new DriverRejectedMail($driver, $reason));
    }
}
