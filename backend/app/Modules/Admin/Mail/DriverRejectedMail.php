<?php

namespace App\Modules\Admin\Mail;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class DriverRejectedMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public User $driver,
        public ?string $reason
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Actualización sobre tu solicitud de conductor',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.driver_rejected',
        );
    }
}
