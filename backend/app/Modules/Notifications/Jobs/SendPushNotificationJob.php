<?php

namespace App\Modules\Notifications\Jobs;

use App\Models\User;
use App\Modules\Notifications\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Collection;

class SendPushNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;

    public int $backoff = 30;

    /**
     * @param  Collection<int, User>|User  $recipients
     * @param  array<string, mixed>  $data
     */
    public function __construct(
        private Collection|User $recipients,
        private string $title,
        private string $body,
        private array $data = []
    ) {}

    public function handle(NotificationService $service): void
    {
        if ($this->recipients instanceof User) {
            $service->sendToUser($this->recipients, $this->title, $this->body, $this->data);
        } else {
            $service->sendToUsers($this->recipients, $this->title, $this->body, $this->data);
        }
    }
}
