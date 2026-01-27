<?php

namespace App\Modules\Admin\Mail;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class DriverApprovedMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public User $driver) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: '¡Tu cuenta de conductor ha sido aprobada!',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.driver_approved',
        );
    }
}
