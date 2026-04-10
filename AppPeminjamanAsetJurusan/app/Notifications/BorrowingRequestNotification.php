<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class BorrowingRequestNotification extends Notification
{
    use Queueable;

    protected $requestDetails;

    public function __construct($requestDetails)
    {
        $this->requestDetails = $requestDetails;
    }

    public function via($notifiable)
    {
        return ['mail', 'database']; // Send via mail and store in database
    }

    public function toMail($notifiable)
    {
        $url = $notifiable->isAdmin() ? route('admin.borrowings.index') : route('officers.borrowings.index');
        $borrowing = $this->requestDetails->load('items.commodity');

        return (new MailMessage)
            ->subject('New Borrowing Request')
            ->view('emails.borrowing_request', [
                'url' => $url,
                'recipientName' => $notifiable->name,
                'borrowing' => $borrowing,
            ]);
    }

    public function toArray($notifiable)
    {
        return [
            'requestDetails' => $this->requestDetails,
        ];
    }
}
