<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;
use App\Models\User;
use App\Models\Student;

class ApprovalNotificationMail extends Mailable
{
    use Queueable, SerializesModels;

    public $status;
    public $studentName;
    public $itemNames;
    public $processedBy;
    public $recipientName;
    public $url;
    public $subject;
    public $message;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($status, Student $student, array $items, User $processor)
    {
        $this->status = $status;
        $this->studentName = $student->name;
        $this->itemNames = implode(', ', $items);
        $this->processedBy = $processor->name;
        $this->recipientName = 'Admin'; // The recipient is the admin
        $this->url = route('admin.borrowings.index'); // A generic URL for the admin to check

        switch ($status) {
            case 'approved':
                $this->subject = 'Notifikasi Persetujuan Peminjaman';
                $this->message = "Peminjaman untuk siswa '{$this->studentName}' telah disetujui oleh '{$this->processedBy}'. Barang: {$this->itemNames}.";
                break;
            case 'rejected':
                $this->subject = 'Notifikasi Penolakan Peminjaman';
                $this->message = "Peminjaman untuk siswa '{$this->studentName}' telah ditolak oleh '{$this->processedBy}'. Barang: {$this->itemNames}.";
                break;
            case 'returned':
                $this->subject = 'Notifikasi Pengembalian Barang';
                $this->message = "Barang telah dikembalikan oleh siswa '{$this->studentName}' dan diproses oleh '{$this->processedBy}'. Barang: {$this->itemNames}.";
                break;
        }
    }

    /**
     * Build the message.
     *
     * @return $this
     */
    public function build()
    {
        $viewName = 'emails.borrowing_' . $this->status;

        // A fallback view in case a specific one doesn't exist
        if (!view()->exists($viewName)) {
            $viewName = 'emails.borrowing_status';
        }

        return $this->subject($this->subject)
                    ->view($viewName, [
                        'recipientName' => $this->recipientName,
                        'message' => $this->message,
                        'url' => $this->url,
                        'lokasi' => null
                    ]);
    }
}
