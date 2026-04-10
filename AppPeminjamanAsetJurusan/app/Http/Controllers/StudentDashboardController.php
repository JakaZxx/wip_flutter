<?php

namespace App\Http\Controllers;

use App\Models\Borrowing;
use App\Models\Student;
use App\Models\Commodity; // Added for total available assets
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class StudentDashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        
        // Get student ID from user
        $student = Student::where('user_id', $user->id)->first();
        
        if (!$student) {
            return redirect()->route('login')->with('error', 'Student profile not found');
        }

        // Statistics
        $totalAvailableAssets = Commodity::where('stock', '>', 0)->count(); // Total available assets
        
        $myActiveBorrowingsCount = Borrowing::where('student_id', $student->id)
            ->where('status', 'approved') // Assuming 'approved' means currently active
            ->count();
        
        $pendingBorrowingsCount = Borrowing::where('student_id', $student->id)
            ->where('status', 'pending')
            ->count();
        
        $approvedOrOverdueBorrowingsCount = Borrowing::where('student_id', $student->id)
            ->whereIn('status', ['approved', 'overdue']) // Combined approved and overdue
            ->count();

        // Data for Borrowing Trend Line Chart (last 6 months)
        $borrowingTrend = [];
        $months = [];
        for ($i = 5; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $monthName = $date->translatedFormat('M');
            $count = Borrowing::where('student_id', $student->id)
                ->whereMonth('created_at', $date->month)
                ->whereYear('created_at', $date->year)
                ->count();
            $borrowingTrend[] = $count;
            $months[] = $monthName;
        }

        // Data for Borrowing Status Pie Chart
        $borrowingStatusCounts = Borrowing::where('student_id', $student->id)
            ->selectRaw('status, count(*) as count')
            ->groupBy('status')
            ->pluck('count', 'status')
            ->toArray();

        $chartStatusLabels = ['approved', 'pending', 'returned', 'overdue', 'rejected'];
        $chartStatusData = [];
        foreach ($chartStatusLabels as $label) {
            $chartStatusData[] = $borrowingStatusCounts[$label] ?? 0;
        }

        // Fetch borrowings due within 2 days for reminders
        $upcomingDueBorrowings = Borrowing::where('student_id', $student->id)
            ->where('status', 'approved')
            ->whereNotNull('return_date')
            ->where('return_date', '<=', now()->addDays(2))
            ->where('return_date', '>=', now())
            ->with('commodities')
            ->get();

        // Active borrowings list
        $activeBorrowingsList = Borrowing::where('student_id', $student->id)
            ->where('status', 'approved')
            ->with('commodities')
            ->latest()
            ->get();

        // Recent requests
        $recentRequests = Borrowing::where('student_id', $student->id)
            ->with('commodities')
            ->latest()
            ->take(5)
            ->get();

        // Borrowing history
        $borrowingHistory = Borrowing::where('student_id', $student->id)
            ->with('commodities')
            ->latest()
            ->get();

        // Fetch unread notifications for student with enriched data and filtering
        $notifications = $user->notifications()
            ->whereNull('read_at')
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get()
            ->map(function ($notification) {
                $data = $notification->data;
                $message = $data['requestDetails']['message'] ?? ($data['message'] ?? 'Notifikasi baru');
                $link = $data['link'] ?? '#';
                $sender = $notification->sender_id ? \App\Models\User::find($notification->sender_id) : null;
                return (object)[
                    'id' => $notification->id,
                    'message' => $message,
                    'link' => $link,
                    'is_read' => $notification->read_at ? true : false,
                    'created_at' => $notification->created_at,
                    'sender' => $sender,
                ];
            });
        $unreadCount = $user->notifications()->whereNull('read_at')->count();

        return view('students.dashboard', compact(
            'totalAvailableAssets',
            'myActiveBorrowingsCount',
            'pendingBorrowingsCount',
            'approvedOrOverdueBorrowingsCount',
            'borrowingTrend',
            'months',
            'chartStatusLabels',
            'chartStatusData',
            'upcomingDueBorrowings',
            'activeBorrowingsList',
            'recentRequests',
            'borrowingHistory',
            'notifications',
            'unreadCount'
        ));
    }
}
