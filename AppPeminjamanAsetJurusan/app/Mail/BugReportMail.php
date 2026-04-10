<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class BugReportMail extends Mailable
{
    use Queueable, SerializesModels;

    public $bugData;

    /**
     * Create a new message instance.
     *
     * @param array $bugData
     * @return void
     */
    public function __construct(array $bugData)
    {
        $this->bugData = $bugData;
    }

    /**
     * Build the message.
     *
     * @return $this
     */
    public function build()
    {
        return $this->subject('Laporan Bug Baru')
                    ->view('emails.bugreport')
                    ->with([
                        'name' => $this->bugData['name'] ?? 'Unknown',
                        'email' => $this->bugData['email'] ?? 'Unknown',
                        'device_type' => $this->bugData['device_type'] ?? '',
                        'bug_type' => $this->bugData['bug_type'] ?? '',
                        'bug_description' => $this->bugData['bug_description'] ?? '',
                        'reported_at' => $this->bugData['reported_at'] ?? now()->toDateTimeString(),
                        'expected_behavior' => $this->bugData['expected_behavior'] ?? '',
                        'bug_image_path' => $this->bugData['bug_image_path'] ?? null,
                    ]);
    }
}
