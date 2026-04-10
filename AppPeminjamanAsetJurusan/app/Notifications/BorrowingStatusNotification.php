<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class BorrowingStatusNotification extends Notification
{
    use Queueable;

    public $status;
    public $messageText;
    public $items;

    /**
     * Create a new notification instance.
     *
     * @return void
     */
    public function __construct($status, $messageText, $items = null)
    {
        $this->status = $status;
        $this->messageText = $messageText;
        $this->items = $items;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return ['mail', 'database'];
    }

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        \Log::info('Inside BorrowingStatusNotification->toMail');
        if ($this->status === 'approved') {
            $subject = 'Peminjaman Disetujui';
        } elseif ($this->status === 'returned') {
            $subject = 'Barang Dikembalikan';
        } else {
            $subject = 'Status Peminjaman';
        }

        $url = $notifiable->isStudent() ? route('students.borrowings.index') : ($notifiable->isAdmin() ? route('admin.borrowings.index') : route('officers.borrowings.index'));

        $mailMessage = (new MailMessage)
            ->subject($subject)
            ->line($this->messageText);

        if ($this->items) {
            foreach ($this->items as $item) {
                $lokasi = $item->commodity->lokasi ?? 'Gudang ' . $item->commodity->jurusan;
                $mailMessage->line($item->commodity->name . ': Silahkan Ambil barang ke ' . $lokasi);
            }
        }

        $mailMessage->action('Lihat Detail', $url);

        return $mailMessage;
    }

    /**
     * Get the array representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function toArray($notifiable)
    {
        return [
            'status' => $this->status,
            'message' => $this->messageText,
            'items' => $this->items,
        ];
    }
}
