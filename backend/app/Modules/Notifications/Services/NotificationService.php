<?php

namespace App\Modules\Notifications\Services;

use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\WebPushConfig;

class NotificationService
{
    public function __construct(
        private Messaging $messaging
    ) {}

    /**
     * Send a push notification to a single user.
     *
     * @param  array<string, mixed>  $data
     */
    public function sendToUser(User $user, string $title, string $body, array $data = []): bool
    {
        if (empty($user->fcm_token)) {
            return false;
        }

        return $this->sendToToken($user->fcm_token, $title, $body, $data, $user);
    }

    /**
     * Send push notification to multiple users.
     *
     * @param  Collection<int, User>  $users
     * @param  array<string, mixed>  $data
     * @return array{sent: int, failed: int}
     */
    public function sendToUsers(Collection $users, string $title, string $body, array $data = []): array
    {
        $tokens = $users
            ->filter(fn (User $user) => ! empty($user->fcm_token))
            ->pluck('fcm_token')
            ->unique()
            ->values()
            ->toArray();

        if (empty($tokens)) {
            return ['sent' => 0, 'failed' => 0];
        }

        return $this->sendToTokens($tokens, $title, $body, $data);
    }

    /**
     * Send notification to a single FCM token.
     *
     * @param  array<string, mixed>  $data
     */
    private function sendToToken(string $token, string $title, string $body, array $data = [], ?User $user = null): bool
    {
        try {
            $message = $this->buildMessage($token, $title, $body, $data);
            $this->messaging->send($message);

            return true;
        } catch (MessagingException $e) {
            $this->handleMessagingException($e, $token, $user);

            return false;
        } catch (\Throwable $e) {
            Log::error('Push notification error', [
                'error' => $e->getMessage(),
                'token' => substr($token, 0, 20).'...',
            ]);

            return false;
        }
    }

    /**
     * Send notification to multiple FCM tokens.
     *
     * @param  array<int, string>  $tokens
     * @param  array<string, mixed>  $data
     * @return array{sent: int, failed: int}
     */
    private function sendToTokens(array $tokens, string $title, string $body, array $data = []): array
    {
        $message = CloudMessage::new()
            ->withNotification(Notification::create($title, $body))
            ->withWebPushConfig($this->getWebPushConfig())
            ->withData($this->prepareData($data));

        try {
            $report = $this->messaging->sendMulticast($message, $tokens);

            // Handle invalid tokens
            $this->handleInvalidTokens($report->unknownTokens());

            return [
                'sent' => $report->successes()->count(),
                'failed' => $report->failures()->count(),
            ];
        } catch (\Throwable $e) {
            Log::error('Multicast push notification error', [
                'error' => $e->getMessage(),
                'tokens_count' => count($tokens),
            ]);

            return ['sent' => 0, 'failed' => count($tokens)];
        }
    }

    /**
     * Build a CloudMessage with proper web push configuration.
     *
     * @param  array<string, mixed>  $data
     */
    private function buildMessage(string $token, string $title, string $body, array $data = []): CloudMessage
    {
        return CloudMessage::new()
            ->toToken($token)
            ->withNotification(Notification::create($title, $body))
            ->withWebPushConfig($this->getWebPushConfig())
            ->withData($this->prepareData($data));
    }

    /**
     * Get web push configuration for PWA notifications.
     */
    private function getWebPushConfig(): WebPushConfig
    {
        return WebPushConfig::fromArray([
            'notification' => [
                'icon' => config('app.url').'/icons/Icon-192.png',
                'badge' => config('app.url').'/icons/Icon-192.png',
                'vibrate' => [100, 50, 100],
                'requireInteraction' => false,
            ],
            'fcm_options' => [
                'link' => config('app.frontend_url', config('app.url')),
            ],
        ]);
    }

    /**
     * Prepare data payload - all values must be strings.
     *
     * @param  array<string, mixed>  $data
     * @return array<string, string>
     */
    private function prepareData(array $data): array
    {
        return array_map(
            fn ($value) => is_string($value) ? $value : json_encode($value),
            $data
        );
    }

    /**
     * Handle messaging exceptions and clean up invalid tokens.
     */
    private function handleMessagingException(MessagingException $e, string $token, ?User $user = null): void
    {
        $errorCode = $e->getCode();

        // Invalid or expired tokens
        if (in_array($errorCode, ['messaging/invalid-registration-token', 'messaging/registration-token-not-registered'])) {
            $this->invalidateToken($token, $user);
        }

        Log::warning('FCM messaging error', [
            'error' => $e->getMessage(),
            'code' => $errorCode,
            'token' => substr($token, 0, 20).'...',
        ]);
    }

    /**
     * Handle invalid tokens from multicast response.
     *
     * @param  array<int, string>  $tokens
     */
    private function handleInvalidTokens(array $tokens): void
    {
        if (empty($tokens)) {
            return;
        }

        User::whereIn('fcm_token', $tokens)->update(['fcm_token' => null]);

        Log::info('Cleaned up invalid FCM tokens', ['count' => count($tokens)]);
    }

    /**
     * Invalidate a user's FCM token.
     */
    private function invalidateToken(string $token, ?User $user = null): void
    {
        if ($user) {
            $user->update(['fcm_token' => null]);
        } else {
            User::where('fcm_token', $token)->update(['fcm_token' => null]);
        }
    }
}
