<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class BorrowingStatusMail extends Mailable
{
    use Queueable, SerializesModels;

    public $status;
    public $messageText;
    public $lokasi;
    public $recipientName;
    public $url;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($status, $messageText, $lokasi, $recipientName, $url)
    {
        $this->status = $status;
        $this->messageText = $messageText;
        $this->lokasi = $lokasi;
        $this->recipientName = $recipientName;
        $this->url = $url;
    }

    /**
     * Build the message.
     *
     * @return $this
     */
    public function build()
    {
        $subject = match($this->status) {
            'approved' => 'Peminjaman Disetujui',
            'rejected' => 'Peminjaman Ditolak',
            'returned' => 'Barang Dikembalikan',
            'stock_empty' => 'Pemberitahuan Stok Kosong',
            default => 'Status Peminjaman'
        };

        $view = 'emails.borrowing_' . $this->status;

        return $this->subject($subject)
                    ->view($view, [
                        'recipientName' => $this->recipientName,
                        'message' => $this->messageText,
                        'lokasi' => $this->lokasi,
                        'url' => $this->url,
                    ]);
    }
}
