<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Student;
use App\Models\Borrowing;
use App\Models\Commodity;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use App\Notifications\BorrowingStatusNotification;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_receives_notification_on_approval()
    {
        Notification::fake();

        $student = Student::factory()->create();
        $commodity = Commodity::factory()->create(['stock' => 5]);
        $borrowing = Borrowing::create([
            'student_id' => $student->id,
            'commodity_id' => $commodity->id,
            'borrow_date' => now(),
            'return_date' => now()->addDays(7),
            'status' => 'pending',
        ]);

        // Simulate approval
        $borrowing->status = 'approved';
        $borrowing->save();

        // Notify the student
        $student->notify(new BorrowingStatusNotification('approved', 'Your borrowing request has been approved.', $commodity->lokasi));

        Notification::assertSentTo(
            [$student],
            BorrowingStatusNotification::class,
            function ($notification, $channels) use ($student) {
                $data = $notification->toArray($student);
                return $data['status'] === 'approved' && $data['message'] === 'Your borrowing request has been approved.';
            }
        );
    }

    public function test_student_receives_notification_on_rejection()
    {
        Notification::fake();

        $student = Student::factory()->create();
        $commodity = Commodity::factory()->create(['stock' => 5]);
        $borrowing = Borrowing::create([
            'student_id' => $student->id,
            'commodity_id' => $commodity->id,
            'borrow_date' => now(),
            'return_date' => now()->addDays(7),
            'status' => 'pending',
        ]);

        // Simulate rejection
        $borrowing->status = 'rejected';
        $borrowing->save();

        // Notify the student
        $student->notify(new BorrowingStatusNotification('rejected', 'Your borrowing request has been rejected.'));

        Notification::assertSentTo(
            [$student],
            BorrowingStatusNotification::class,
            function ($notification, $channels) use ($student) {
                $data = $notification->toArray($student);
                return $data['status'] === 'rejected' && $data['message'] === 'Your borrowing request has been rejected.';
            }
        );
    }
}
