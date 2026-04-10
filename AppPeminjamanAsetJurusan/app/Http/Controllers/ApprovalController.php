<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Borrowing;
use App\Models\Student;
use App\Models\Commodity;
use App\Models\SchoolClass;

use App\Notifications\BorrowingStatusNotification;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;

class ApprovalController extends Controller
{
    public function approve(Request $request, $id)
    {
        $borrowing = Borrowing::with('items.commodity')->findOrFail($id);
        $user = auth()->user();
        $itemIds = $request->input('items', []);

        if (empty($itemIds)) {
            return redirect()->back()->with('error', 'Pilih setidaknya satu barang untuk disetujui.');
        }

        $emptyStockItems = [];
        $approvedItems = [];
        $skippedItems = [];

        $student = null;
        try {
            DB::transaction(function () use ($borrowing, $user, $itemIds, &$emptyStockItems, &$approvedItems, &$skippedItems, &$student) {
                foreach ($itemIds as $itemId) {
                    $item = $borrowing->items()->findOrFail($itemId);
                    $commodity = $item->commodity;

                    if ($item->status !== 'pending') {
                        continue;
                    }

                    if ($user->isOfficer() && $user->jurusan && strtolower($commodity->jurusan) !== strtolower($user->jurusan)) {
                        $skippedItems[] = $commodity->name . ' (Jurusan: ' . $commodity->jurusan . ')';
                        continue;
                    }

                    $decrement = min($commodity->stock, $item->quantity);
                    $commodity->decrement('stock', $decrement);

                    if ($commodity->stock == 0) {
                        $emptyStockItems[] = $commodity->name;
                    }
                    $item->update([
                        'status' => 'approved'
                    ]);
                    $approvedItems[] = $commodity->name;
                }

                // Update borrowing status based on items
                $this->updateBorrowingStatus($borrowing);

                $student = Student::find($borrowing->student_id);
            });

            // Send notification outside transaction

            if ($student && $student->user && !empty($approvedItems)) {
                $approvedBorrowingItems = $borrowing->items()->whereIn('id', $itemIds)->get();

                $student->user->notify(new \App\Notifications\BorrowingStatusNotification('approved', 'Peminjaman Anda telah disetujui.', $approvedBorrowingItems));

                // Fire the event for real-time notification
                \App\Events\NotificationSent::dispatch($student->user, 'Peminjaman Anda telah disetujui.');
            }

            // Notify officers and admins if any item has stock 0
            if (!empty($emptyStockItems)) {
                $message = "Stock dari " . implode(', ', $emptyStockItems) . " kosong";
                $admins = \App\Models\User::where('role', 'admin')->get();
                $emptyStockJurusans = [];
                foreach ($emptyStockItems as $itemName) {
                    $commodity = \App\Models\Commodity::where('name', $itemName)->first();
                    if ($commodity && $commodity->jurusan) {
                        $emptyStockJurusans[] = $commodity->jurusan;
                    }
                }
                $officers = \App\Models\User::where('role', 'officer')->whereIn('jurusan', array_unique($emptyStockJurusans))->get();
                $recipients = $admins->merge($officers);
                // Also include the current user if admin or officer to see the notification
                if ($user->role === 'admin' || $user->role === 'officer') {
                    $recipients->push($user);
                }
                foreach ($recipients->unique('id') as $recipient) {
                    $url = $recipient->isAdmin() ? route('admin.assets.index') : route('officers.assets.index');
                    \Illuminate\Support\Facades\Mail::to($recipient->email)->send(new \App\Mail\BorrowingStatusMail('stock_empty', $message, null, $recipient->name, $url));
                }
            }
        } catch (\Exception $e) {
            return redirect()->back()->with('error', $e->getMessage());
        }

        $successMsg = 'Barang yang dipilih telah disetujui.';
        if (!empty($skippedItems)) {
            $successMsg .= ' Barang berikut dilewati karena bukan jurusan Anda: ' . implode(', ', $skippedItems) . '.';
        }
        return redirect()->back()->with('success', $successMsg);
    }

    private function updateBorrowingStatus($borrowing)
    {
        // Fetch latest item statuses directly from DB to avoid relation caching issues
        $items = \App\Models\BorrowingItem::where('borrowing_id', $borrowing->id)->get();
        $hasPending = $items->contains(fn($item) => $item->status === 'pending');
        $hasApproved = $items->contains(fn($item) => $item->status === 'approved');
        $hasRejected = $items->contains(fn($item) => $item->status === 'rejected');
        $hasReturned = $items->contains(fn($item) => $item->status === 'returned');
        $allApproved = $items->every(fn($item) => $item->status === 'approved');
        $allRejected = $items->every(fn($item) => $item->status === 'rejected');
        $allReturned = $items->every(fn($item) => $item->status === 'returned');

        if ($hasPending) {
            if ($hasApproved || $hasReturned) {
                $borrowing->status = 'partially_approved';
            } else {
                $borrowing->status = 'pending';
            }
        } else {
            if ($allReturned) {
                $borrowing->status = 'returned';
            } elseif ($hasReturned) {
                $borrowing->status = 'partially_returned';
            } elseif ($allApproved) {
                $borrowing->status = 'approved';
            } elseif ($hasApproved && $hasRejected) {
                $borrowing->status = 'partial';
            } elseif ($allRejected) {
                $borrowing->status = 'rejected';
            } else {
                $borrowing->status = 'pending';
            }
        }

        $borrowing->save();
    }

    public function reject(Request $request, $id)
    {
        $borrowing = Borrowing::with('items.commodity')->findOrFail($id);
        $user = auth()->user();
        $itemIds = $request->input('items', []);

        if (empty($itemIds)) {
            return redirect()->back()->with('error', 'Pilih setidaknya satu barang untuk ditolak.');
        }

        $rejectedItems = [];
        $skippedItems = [];

        $student = null;
        try {
            DB::transaction(function () use ($borrowing, $user, $itemIds, &$rejectedItems, &$skippedItems, &$student) {
                foreach ($itemIds as $itemId) {
                    $item = $borrowing->items()->findOrFail($itemId);
                    $commodity = $item->commodity;

                    if ($item->status !== 'pending') {
                        continue;
                    }

                    if ($user->isOfficer() && $user->jurusan && strtolower($commodity->jurusan) !== strtolower($user->jurusan)) {
                        $skippedItems[] = $commodity->name . ' (Jurusan: ' . $commodity->jurusan . ')';
                        continue;
                    }

                    $item->update(['status' => 'rejected']);
                    $rejectedItems[] = $commodity->name;
                }

                // Update borrowing status based on items
                $this->updateBorrowingStatus($borrowing);

                $student = Student::find($borrowing->student_id);
            });

            // Send notification outside transaction
            if ($student && $student->user && !empty($rejectedItems)) {
                $itemNames = implode(', ', $rejectedItems);
                $message = "Maaf, peminjaman Anda untuk barang: {$itemNames} ditolak.";
                $student->user->notify(new BorrowingStatusNotification('rejected', $message));

                // Fire the event for real-time notification
                \App\Events\NotificationSent::dispatch($student->user, $message);
            }
        } catch (\Exception $e) {
            return redirect()->back()->with('error', $e->getMessage());
        }

        $successMsg = 'Barang yang dipilih telah ditolak.';
        if (!empty($skippedItems)) {
            $successMsg .= ' Barang berikut dilewati karena bukan jurusan Anda: ' . implode(', ', $skippedItems) . '.';
        }
        return redirect()->back()->with('success', $successMsg);
    }

    public function return(Request $request, $id)
    {
        Log::info('ApprovalController::return started', ['borrowing_id' => $id, 'user_id' => auth()->id(), 'user_role' => auth()->user()->role]);
        $borrowing = Borrowing::with('items.commodity')->findOrFail($id);
        $user = auth()->user();
        $itemIds = $request->input('items');

        $itemsToProcess = collect();
        if ($itemIds !== null) {
            if (empty($itemIds)) {
                return redirect()->back()->with('error', 'Pilih setidaknya satu barang untuk dikembalikan.');
            }
            $itemsToProcess = $borrowing->items()->whereIn('id', $itemIds)->get();
        } else {
            $itemsToProcess = $borrowing->items;
        }

        $returnedCommodities = [];
        $skippedCommodities = [];

        $student = null;
        try {
            DB::transaction(function () use ($borrowing, $user, $itemsToProcess, &$returnedCommodities, &$skippedCommodities, &$student, $id) {
                Log::info('ApprovalController::return transaction started', ['borrowing_id' => $id, 'user_id' => $user->id]);
                foreach ($itemsToProcess as $item) {
                    $commodity = $item->commodity;
                    if ($user->isOfficer() && $user->jurusan && strtolower($commodity->jurusan) !== strtolower($user->jurusan)) {
                        $skippedCommodities[] = $commodity->name . ' (Jurusan: ' . $commodity->jurusan . ')';
                        Log::info('ApprovalController::return skipped commodity', ['commodity_id' => $commodity->id, 'commodity_name' => $commodity->name, 'jurusan' => $commodity->jurusan, 'user_jurusan' => $user->jurusan]);
                        continue;
                    }

                    // Only process items that are currently approved
                    if ($item->status == 'approved') {
                        $commodity->increment('stock', $item->quantity);
                        $returnedCommodities[] = $commodity->name;
                        Log::info('ApprovalController::return commodity returned', ['commodity_id' => $commodity->id, 'commodity_name' => $commodity->name, 'quantity' => $item->quantity, 'new_stock' => $commodity->stock]);
                        // Update corresponding item status
                        $item->update(['status' => 'returned']);
                        Log::info('ApprovalController::return BorrowingItem status updated', ['item_id' => $item->id, 'new_status' => $item->status]);
                    }
                }

                // Update borrowing status
                $this->updateBorrowingStatus($borrowing);
                Log::info('ApprovalController::return Borrowing status after updateBorrowingStatus', ['borrowing_id' => $borrowing->id, 'new_status' => $borrowing->status]);

                $borrowing->refresh(); // Refresh to get the latest status

                if ($borrowing->status === 'returned') {
                    $borrowing->return_date = now();
                }

                $borrowing->returned_by = $user->id; // Set returned_by to current user
                $borrowing->save();

                $student = Student::find($borrowing->student_id);
                Log::info('ApprovalController::return transaction completed', ['borrowing_id' => $id, 'returned_commodities' => $returnedCommodities, 'skipped_commodities' => $skippedCommodities]);
            });

            // Send notification outside transaction
            if ($student && $student->user) {
                $itemNames = implode(', ', $returnedCommodities);
                $message = "Barang ({$itemNames}) telah berhasil dikembalikan.";
                if (!empty($skippedCommodities)) {
                    $message .= " Barang berikut belum diproses: " . implode(', ', $skippedCommodities) . " (menunggu officer jurusan terkait).";
                }
                $message .= " Terima kasih!";
                $student->user->notify(new BorrowingStatusNotification('returned', $message));

                // Fire the event for real-time notification
                \App\Events\NotificationSent::dispatch($student->user, $message);

                Log::info('ApprovalController::return notification sent', ['student_id' => $student->id, 'message' => $message]);
            }
            Log::info('ApprovalController::return ended successfully', ['borrowing_id' => $id]);
        } catch (\Exception $e) {
            Log::error('ApprovalController::return error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString(), 'borrowing_id' => $id, 'user_id' => $user->id]);
            Log::error('ApprovalController::return ended with error', ['borrowing_id' => $id]);
            return redirect()->back()->with('error', $e->getMessage());
        }

        $successMsg = 'Barang berhasil dikembalikan.';
        if (!empty($skippedCommodities)) {
            $successMsg .= ' Beberapa barang dilewati karena bukan jurusan Anda dan masih menunggu pemrosesan.';
        }
        return redirect()->back()->with('success', $successMsg);
    }

    public function index(Request $request)
    {
        $user = auth()->user();
        $search = $request->input('search');
        $status = $request->input('status');
        $jurusan = $request->input('jurusan');
        $class = $request->input('class');

        $query = \App\Models\Borrowing::with(['student.user', 'student.schoolClass', 'items.commodity']);

        if ($user->isOfficer()) {
            $query->whereHas('commodities', function($q) use ($user) {
                $q->where('jurusan', $user->jurusan);
            });
        }

        if (!empty($search)) {
            $query->where(function($q) use ($search) {
                $q->whereHas('student', function($sq) use ($search) {
                    $sq->where('name', 'like', "%{$search}%");
                })
                ->orWhereHas('commodities', function($cq) use ($search) {
                    $cq->where('name', 'like', "%{$search}%");
                });
            });
        }

        if (!empty($status)) {
            $query->where('status', $status);
        }

        if (!empty($jurusan) && $user->isAdmin()) {
            $query->whereHas('commodities', function($q) use ($jurusan) {
                $q->where('jurusan', $jurusan);
            });
        }

        if (!empty($class)) {
            $query->whereHas('student.schoolClass', function($q) use ($class) {
                $q->where('name', $class);
            });
        }

        $borrowings = $query->orderBy('created_at', 'desc')->paginate(6)->appends(request()->query());

        $statusList = ['pending', 'approved', 'rejected', 'returned', 'partial', 'partially_approved', 'partially_returned'];
        $jurusanList = \App\Models\Commodity::select('jurusan')->distinct()->pluck('jurusan');
        $classList = \App\Models\SchoolClass::select('name')->distinct()->pluck('name');

        // Fetch notifications for officers and admins
        $notifications = collect();
        $unreadCount = 0;
        if ($user->isOfficer() || $user->isAdmin()) {
            $notifications = $user->notifications()->where('created_at', '>', $user->last_seen_notifications ?? now()->subDays(30))->orderBy('created_at', 'desc')->take(10)->get();
            $unreadCount = $user->unreadNotifications()->count();
        }

        // Update last seen notifications for officers and admins after fetching notifications
        if ($user->isOfficer() || $user->isAdmin()) {
            $user->update(['last_seen_notifications' => now()]);
        }

        $data = compact('borrowings', 'statusList', 'jurusanList', 'classList', 'notifications', 'unreadCount');

        if ($user->isOfficer()) {
            return view('officers.borrowings.index', $data);
        } else {
            return view('admin.borrowings.index', $data);
        }
    }

    public function indexData(Request $request)
    {
        $user = auth()->user();
        $search = $request->input('search');
        $status = $request->input('status');
        $jurusan = $request->input('jurusan');
        $class = $request->input('class');

        $query = \App\Models\Borrowing::with([
            'student' => function($q) {
                $q->select('id', 'user_id', 'name', 'school_class_id');
            },
            'student.user' => function($q) {
                $q->select('id', 'name', 'profile_picture');
            },
            'student.schoolClass' => function($q) {
                $q->select('id', 'name');
            },
            'items' => function($q) {
                $q->select('id', 'borrowing_id', 'commodity_id', 'quantity', 'status', 'return_photo');
            },
            'items.commodity' => function($q) {
                $q->select('id', 'name', 'code', 'jurusan', 'photo');
            }
        ]);

        if ($user->isOfficer()) {
            $query->whereHas('items.commodity', function($q) use ($user) {
                $q->where('jurusan', $user->jurusan);
            });
        }

        if (!empty($search)) {
            $query->where(function($q) use ($search) {
                $q->whereHas('student', function($sq) use ($search) {
                    $sq->where('name', 'like', "%{$search}%");
                })
                ->orWhereHas('items.commodity', function($cq) use ($search) {
                    $cq->where('name', 'like', "%{$search}%");
                });
            });
        }

        if (!empty($status)) {
            $query->where('status', $status);
        }

        if (!empty($jurusan) && $user->isAdmin()) {
            $query->whereHas('items.commodity', function($q) use ($jurusan) {
                $q->where('jurusan', $jurusan);
            });
        }

        if (!empty($class)) {
            $query->whereHas('student.schoolClass', function($q) use ($class) {
                $q->where('name', $class);
            });
        }

        $borrowings = $query->orderBy('created_at', 'desc')->paginate(15)->appends(request()->query());

        $data = compact('borrowings');

        if ($user->isOfficer()) {
            return view('officers.borrowings.index', $data);
        } else {
            return view('admin.borrowings._cards', $data);
        }
    }

    public function getModalData(Request $request, $borrowingId)
    {
        $user = auth()->user();
        $borrowing = Borrowing::with([
            'items' => function($q) use ($user) {
                $q->select('id', 'borrowing_id', 'commodity_id', 'quantity', 'status')
                  ->with(['commodity' => function($cq) {
                      $cq->select('id', 'name', 'jurusan');
                  }]);
            }
        ])->findOrFail($borrowingId);

        // Filter items based on officer's jurusan if applicable
        $officerJurusan = $user->isOfficer() ? $user->jurusan : null;
        $items = $borrowing->items->filter(function($item) use ($officerJurusan) {
            return $item->status == 'pending' &&
                   (!$officerJurusan || strtolower($item->commodity->jurusan) == strtolower($officerJurusan));
        });

        return response()->json([
            'items' => $items->map(function($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->commodity->name,
                    'quantity' => $item->quantity
                ];
            })
        ]);
    }

    public function history()
    {
        $user = auth()->user();
        if ($user->isOfficer()) {
            $borrowings = \App\Models\Borrowing::with(['student.user', 'commodities'])
                ->whereHas('commodities', function($query) use ($user) {
                    $query->where('jurusan', $user->jurusan);
                })
                ->whereIn('status', ['approved', 'rejected', 'returned', 'partial', 'partially_approved', 'partially_returned'])
                ->orderBy('created_at', 'desc')
                ->get();

            // Fetch notifications for officers
            $notifications = collect();
            $unreadCount = 0;
            if ($user->isOfficer()) {
                $notifications = $user->notifications()->where('created_at', '>', $user->last_seen_notifications ?? now()->subDays(30))->orderBy('created_at', 'desc')->take(10)->get();
                $unreadCount = $user->unreadNotifications()->count();
            }

            return view('officers.borrowings.history', compact('borrowings', 'notifications', 'unreadCount'));
        } else {
            $borrowings = \App\Models\Borrowing::with(['student.user', 'commodities'])
                ->whereIn('status', ['approved', 'rejected', 'returned', 'partial', 'partially_approved', 'partially_returned'])
                ->orderBy('created_at', 'desc')
                ->get();

            // Fetch notifications for admins
            $notifications = collect();
            $unreadCount = 0;
            if ($user->isAdmin()) {
                $notifications = $user->notifications()->where('created_at', '>', $user->last_seen_notifications ?? now()->subDays(30))->orderBy('created_at', 'desc')->take(10)->get();
                $unreadCount = $user->unreadNotifications()->count();
            }

            return view('admin.borrowings.history', compact('borrowings', 'notifications', 'unreadCount'));
        }
    }
}