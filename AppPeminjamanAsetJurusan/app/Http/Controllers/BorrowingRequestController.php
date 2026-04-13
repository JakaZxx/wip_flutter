<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Student;
use App\Models\Commodity;
use App\Models\Borrowing;
use App\Models\BorrowingItem;
use App\Models\User;
use App\Models\Cart;
use App\Models\CartItem;
use App\Notifications\BorrowingRequestNotification;
use App\Notifications\BorrowingStatusNotification;

use Illuminate\Support\Facades\Validator;

class BorrowingRequestController extends Controller
{
    /**
     * Form pengajuan peminjaman
     */
    public function create(Request $request)
    {
        try {
            $search = $request->input('search');
            $jurusan = $request->input('jurusan');

            // Get cart items for current user
            $cart = Cart::getOrCreateForUser(auth()->id());
            $cartItems = $cart->items()->with('commodity')->get();
            $cartQuantities = $cartItems->pluck('quantity', 'commodity_id')->toArray();

            // Override cart quantities with submitted cart_quantities from filter form if present
            $submittedCartQuantities = $request->input('cart_quantities', []);
            if (!empty($submittedCartQuantities)) {
                foreach ($submittedCartQuantities as $commodityId => $quantity) {
                    $cartQuantities[$commodityId] = (int) $quantity;
                }
            }

            $query = Commodity::where('stock', '>', 0);

            if (!empty($search)) {
                $query->where(function($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('code', 'like', "%{$search}%");
                });
            }

            if (!empty($jurusan)) {
                $query->where('jurusan', $jurusan);
            }

            $schoolClasses = \App\Models\SchoolClass::all();
            $jurusans = Commodity::distinct('jurusan')->pluck('jurusan');
            $user = auth()->user();

            if ($user->isStudent()) {
                $commodities = $query->orderBy('name', 'asc')->paginate(12);

                // Fetch all commodities in cartQuantities that are not in the filtered commodities list
                $selectedCommodityIds = array_keys($cartQuantities);
                $extraCommodities = Commodity::whereIn('id', $selectedCommodityIds)
                    ->whereNotIn('id', $commodities->pluck('id')->toArray())
                    ->get();

                return view('students.borrowings.request.create', compact('commodities', 'jurusans', 'cartQuantities', 'extraCommodities'));
            }

            // Untuk Admin dan Officer, tampilannya sama
            if ($user->isAdmin() || $user->isOfficer()) {
                $commodities = $query->orderBy('name', 'asc')->get();
                $students = Student::with('schoolClass', 'user')->get();
                $studentClasses = $students->pluck('schoolClass.name')->filter()->unique()->values();

                // Fetch all commodities in cartQuantities that are not in the filtered commodities list
                $selectedCommodityIds = array_keys($cartQuantities);
                $extraCommodities = Commodity::whereIn('id', $selectedCommodityIds)
                    ->whereNotIn('id', $commodities->pluck('id')->toArray())
                    ->get();

                if ($user->isOfficer()) {
                     // Officer view
                     return view('officers.borrowings.request.create', compact('schoolClasses', 'commodities', 'students', 'jurusans', 'studentClasses', 'cartQuantities', 'extraCommodities'));
                } else {
                     // Admin view
                     return view('admin.borrowings.request.create', compact('schoolClasses', 'commodities', 'students', 'jurusans', 'studentClasses', 'cartQuantities', 'extraCommodities'));
                }
            } else {
                return redirect()->back()->with('error', 'Unauthorized access.');
            }
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@create - Error occurred', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
                'request_data' => $request->all(),
                'trace' => $e->getTraceAsString()
            ]);
            return redirect()->back()->with('error', 'Terjadi kesalahan saat memuat form pengajuan peminjaman.');
        }
    }

    /**
     * Simpan pengajuan peminjaman
     */
    public function store(Request $request)
    {
        \Log::debug('BorrowingRequestController@store - Request received', [
            'user_id' => auth()->id(),
            'user_role' => auth()->user()->role,
            'request_data' => $request->all()
        ]);

        $user = auth()->user();

        $validationRules = [
            'borrow_date' => 'required|date',
            'borrow_time' => 'required|date_format:H:i',
            'return_date' => 'required|date|after_or_equal:borrow_date',
            'return_time' => 'required|date_format:H:i',
            'tujuan'      => 'required|string|max:255',
        ];

        if ($user->isAdmin()) {
            $validationRules['borrow_date'] .= '|after_or_equal:today';
            if ($request->has('borrow_for_self') && $request->borrow_for_self) {
                $validationRules['student_id'] = 'nullable';
            } else {
                $validationRules['student_id'] = 'required|exists:students,id';
            }
        } elseif ($user->isOfficer()) {
            $validationRules['borrow_date'] .= '|after_or_equal:today';
            if ($request->has('borrow_for_self') && $request->borrow_for_self) {
                $validationRules['student_id'] = 'nullable';
            } else {
                $validationRules['student_id'] = 'required|exists:students,id';
            }
        } else {
            // For students, borrow_date must be today
            $validationRules['borrow_date'] = 'required|date|date_equals:today';
        }

        $request->validate($validationRules);

        // Get items from cart instead of request
        $cart = Cart::getOrCreateForUser($user->id);
        $cartItems = $cart->items()->with('commodity')->get();

        // Debug log cart items count and details
        \Log::debug('BorrowingRequestController@store - Cart items count: ' . $cartItems->count());
        foreach ($cartItems as $item) {
            \Log::debug('CartItem: commodity_id=' . $item->commodity_id . ', quantity=' . $item->quantity);
        }

        if ($cartItems->isEmpty()) {
            \Log::debug('BorrowingRequestController@store - Cart is empty, redirecting back');
            $validator = Validator::make($request->all(), []);
            $validator->errors()->add('cart', 'Anda harus memilih setidaknya satu barang.');
            return back()->withErrors($validator)->withInput();
        }

        $items = [];
        foreach ($cartItems as $cartItem) {
            $items[$cartItem->commodity_id] = $cartItem->quantity;
        }

        // --- Pengecekan Stok ---
        $stockErrors = [];
        foreach ($items as $id => $quantity) {
            $commodity = Commodity::findOrFail($id);
            if ($commodity->stock < $quantity) {
                $stockErrors[] = "Stok untuk barang '{$commodity->name}' tidak mencukupi.";
            }
        }

        if (!empty($stockErrors)) {
            $validator = Validator::make($request->all(), []);
            foreach ($stockErrors as $error) {
                $validator->errors()->add('stock', $error);
            }
            return back()->withErrors($validator)->withInput();
        }

        // --- Penentuan Siswa ---
        if ($user->isAdmin()) {
            if ($request->has('borrow_for_self') && $request->borrow_for_self) {
                // Admin borrowing for themselves
                $student = Student::firstOrCreate(['user_id' => $user->id], ['name' => $user->name]);
            } else {
                // Admin borrowing for another student
                $student = Student::findOrFail($request->student_id);
            }
            $borrowDate = $request->borrow_date;
        } elseif ($user->isOfficer()) {
            if ($request->has('borrow_for_self') && $request->borrow_for_self) {
                // Officer borrowing for themselves
                $student = Student::firstOrCreate(['user_id' => $user->id], ['name' => $user->name]);
            } else {
                // Officer borrowing for another student
                $student = Student::findOrFail($request->student_id);
            }
            $borrowDate = $request->borrow_date;
        } else {
            // Student borrowing for themselves
            $student = Student::firstOrCreate(['user_id' => $user->id], ['name' => $user->name]);
            $borrowDate = now()->toDateString(); // Set to today's date for students
        }

        // --- Buat Record Peminjaman dalam Transaksi ---
        try {
            DB::transaction(function () use ($request, $student, $items, $borrowDate) {
                \Log::debug('BorrowingRequestController@store - Starting transaction', [
                    'student_id' => $student->id,
                    'items_count' => count($items),
                    'request_data' => $request->all()
                ]);

                $borrowingData = [
                    'student_id'  => $student->id,
                    'borrow_date' => $borrowDate,
                    'borrow_time' => $request->borrow_time,
                    'return_date' => $request->return_date,
                    'return_time' => $request->return_time,
                    'status'      => 'pending',
                    'tujuan'      => $request->tujuan,
                ];

                \Log::debug('BorrowingRequestController@store - Creating borrowing with data', $borrowingData);

                $borrowing = Borrowing::create($borrowingData);

                \Log::debug('BorrowingRequestController@store - Borrowing created', ['borrowing_id' => $borrowing->id]);

                $jurusansToNotify = [];

                foreach ($items as $id => $quantity) {
                    \Log::debug('BorrowingRequestController@store - Creating item', ['commodity_id' => $id, 'quantity' => $quantity]);

                    $borrowing->items()->create([
                        'commodity_id' => $id,
                        'quantity'     => $quantity,
                        'status'       => 'pending',
                    ]);

                    $commodity = Commodity::find($id);
                    if ($commodity) {
                        if ($commodity->jurusan) {
                            $jurusansToNotify[$commodity->jurusan] = true;
                        }
                    } else {
                        throw new \Exception("Commodity with ID {$id} not found");
                    }
                }

                \Log::debug('BorrowingRequestController@store - Items created and stock decremented');

                // --- Notifikasi ---
                $admins = User::where('role', 'admin')->get();
                $officers = User::where('role', 'officer')->whereIn('jurusan', array_keys($jurusansToNotify))->get();

                // Gabungkan admin dan officer untuk notifikasi
                $recipients = $admins->merge($officers);

                foreach ($recipients as $recipient) {
                    // Jangan kirim notifikasi ke diri sendiri jika admin/officer yang membuat
                    if ($recipient->id !== auth()->id()) {
                        $recipient->notify(new BorrowingRequestNotification($borrowing));
                    }
                }

                \Log::debug('BorrowingRequestController@store - Transaction completed successfully');
            });
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@store - Transaction failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'request_data' => $request->all(),
                'student_id' => $student->id ?? null,
                'items' => $items ?? []
            ]);
            $validator = Validator::make($request->all(), []);
            $validator->errors()->add('general', 'Terjadi kesalahan saat menyimpan pengajuan peminjaman: ' . $e->getMessage());
            return back()->withErrors($validator)->withInput();
        }

        // Clear cart after successful borrowing request
        $cart->clear();

        if ($user->isAdmin()) {
            $redirectRoute = 'admin.borrowings.index';
        } elseif ($user->isOfficer()) {
            $redirectRoute = 'officers.borrowings.index';
        } else {
            $redirectRoute = 'students.borrowings.index';
        }

        return redirect()->route($redirectRoute)
                         ->with('success', 'Pengajuan peminjaman berhasil dikirim! Silakan tunggu persetujuan.');
    }

    /**
     * Daftar peminjaman siswa (dengan pagination)
     */
    public function studentIndex()
    {
        try {
            $student = Student::where('user_id', auth()->id())->first();

            if (!$student) {
                return redirect()->route('students.dashboard')
                    ->with('error', 'Data siswa tidak ditemukan.');
            }

            $borrowings = Borrowing::where('student_id', $student->id)
                ->with(['commodities', 'items.commodity'])
                ->orderBy('created_at', 'desc')
                ->paginate(6)->appends(request()->query());

            // Update last seen notifications for students
            $user = auth()->user();
            $user->update(['last_seen_notifications' => now()]);

            return view('students.borrowings.index', compact('borrowings'));
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@studentIndex - Error occurred', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
                'trace' => $e->getTraceAsString()
            ]);
            return redirect()->route('students.dashboard')->with('error', 'Terjadi kesalahan saat memuat daftar peminjaman.');
        }
    }

    /**
     * Detail peminjaman siswa
     */
    public function studentShow($id)
    {
        try {
            $student = Student::where('user_id', auth()->id())->first();

            if (!$student) {
                return redirect()->route('students.dashboard')
                    ->with('error', 'Data siswa tidak ditemukan.');
            }

            $borrowing = Borrowing::with(['commodities', 'items'])
                ->where('id', $id)
                ->where('student_id', $student->id)
                ->first();

            if (!$borrowing) {
                return redirect()->route('students.borrowings.index')
                    ->with('error', 'Peminjaman tidak ditemukan.');
            }

            return view('students.borrowings.show', compact('borrowing'));
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@studentShow - Error occurred', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
                'borrowing_id' => $id,
                'trace' => $e->getTraceAsString()
            ]);
            return redirect()->route('students.borrowings.index')->with('error', 'Terjadi kesalahan saat memuat detail peminjaman.');
        }
    }

    public function officerShow($id)
    {
        try {
            $student = Student::where('user_id', auth()->id())->first();

            if (!$student) {
                return redirect()->route('officers.dashboard')
                    ->with('error', 'Data peminjam tidak ditemukan.');
            }

            $borrowing = Borrowing::with(['commodities', 'items'])
                ->where('id', $id)
                ->where('student_id', $student->id)
                ->first();

            if (!$borrowing) {
                return redirect()->route('officers.borrowings.my')
                    ->with('error', 'Peminjaman tidak ditemukan.');
            }

            return view('officers.borrowings.show', compact('borrowing'));
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@officerShow - Error occurred', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
                'borrowing_id' => $id,
                'trace' => $e->getTraceAsString()
            ]);
            return redirect()->route('officers.borrowings.my')->with('error', 'Terjadi kesalahan saat memuat detail peminjaman.');
        }
    }

    /**
     * Form pengembalian barang
     */
    public function returnForm($id)
    {
        $student = Student::where('user_id', auth()->id())->first();
        if (!$student) {
            return redirect()->route('students.dashboard')->with('error', 'Data siswa tidak ditemukan.');
        }

        $borrowing = Borrowing::with('commodities')
            ->where('id', $id)
            ->where('student_id', $student->id)
            ->where('status', 'approved')
            ->first();

        if (!$borrowing) {
            return redirect()->route('students.borrowings.index')
                ->with('error', 'Peminjaman tidak ditemukan atau tidak bisa dikembalikan.');
        }

        return view('students.borrowings.return', compact('borrowing'));
    }

    /**
     * Proses pengembalian barang
     */
    public function processReturn(Request $request, $id)
    {
        $student = Student::where('user_id', auth()->id())->first();
        if (!$student) {
            return redirect()->route('students.dashboard')->with('error', 'Data siswa tidak ditemukan.');
        }

        $borrowing = Borrowing::with('commodities')->where('id', $id)
            ->where('student_id', $student->id)
            ->where('status', 'approved')
            ->first();

        if (!$borrowing) {
            return redirect()->route('students.borrowings.index')
                ->with('error', 'Peminjaman tidak valid.');
        }

        $request->validate([
            'condition'    => 'required|in:Baik,Rusak',
            'return_photo' => 'nullable|image|mimes:jpg,jpeg,png|max:10000',
        ]);

        DB::transaction(function () use ($request, $borrowing, $student) {
            $photoPath = null;
            if ($request->hasFile('return_photo')) {
                $photoPath = $request->file('return_photo')->store('returns', 'public');
            }

            // Update data pengembalian
            $borrowing->update([
                'status'           => 'returned',
                'return_condition' => $request->condition,
                'return_photo'     => $photoPath,
                'return_date'      => now(),
            ]);

            $jurusansToNotify = [];
            // Update stok barang
            foreach ($borrowing->commodities as $commodity) {
                $commodity->increment('stock', $commodity->pivot->quantity);
                if ($commodity->jurusan) {
                    $jurusansToNotify[$commodity->jurusan] = true;
                }
            }

            // Notifikasi admin & officer
            $admins   = User::where('role', 'admin')->get();
            $officers = User::where('role', 'officer')
                ->whereIn('jurusan', array_keys($jurusansToNotify))
                ->get();

            $itemNames = $borrowing->commodities->pluck('name')->join(', ');
            $message  = "Barang peminjaman ({$itemNames}) oleh {$student->name} telah dikembalikan.";

            // Notify student
            $student->user->notify(new \App\Notifications\BorrowingStatusNotification('returned', $message));

            foreach ($admins as $admin) {
                $admin->notify(new \App\Notifications\BorrowingStatusNotification('returned', $message));
            }

            foreach ($officers as $officer) {
                $officer->notify(new \App\Notifications\BorrowingStatusNotification('returned', $message));
            }
        });

        return redirect()->route('students.borrowings.index')
            ->with('success', 'Barang berhasil dikembalikan!');
    }

    /**
     * Form pengembalian barang per item
     */
    public function returnItemForm($itemId)
    {
        try {
            \Log::info('BorrowingRequestController@returnItemForm - Starting', [
                'user_id' => auth()->id(),
                'item_id' => $itemId
            ]);

            $student = Student::where('user_id', auth()->id())->firstOrFail();

            $item = BorrowingItem::with('borrowing', 'commodity')
                ->where('id', $itemId)
                ->whereHas('borrowing', function($q) use ($student) {
                    $q->where('student_id', $student->id);
                })
                ->firstOrFail();

            if ($item->status !== 'approved') {
                \Log::warning('BorrowingRequestController@returnItemForm - Item not approved', [
                    'item_id' => $itemId,
                    'status' => $item->status
                ]);
                $redirectRoute = auth()->user()->isStudent() ? 'students.borrowings.index' : 'officers.borrowings.my';
                return redirect()->route($redirectRoute)->with('error', 'Item ini tidak bisa dikembalikan saat ini.');
            }

            \Log::info('BorrowingRequestController@returnItemForm - Success', [
                'item_id' => $itemId,
                'borrowing_id' => $item->borrowing_id
            ]);

            $view = auth()->user()->isStudent() ? 'students.borrowings.return' : 'officers.borrowings.return';
            return view($view, compact('item'));
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@returnItemForm - Error occurred', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
                'item_id' => $itemId,
                'trace' => $e->getTraceAsString()
            ]);
            $redirectRoute = auth()->user()->isStudent() ? 'students.borrowings.index' : 'officers.borrowings.my';
            return redirect()->route($redirectRoute)->with('error', 'Terjadi kesalahan saat memuat form pengembalian.');
        }
    }

    /**
     * Proses pengembalian barang per item
     */
    public function processReturnItem(Request $request, $itemId)
    {
        try {
            \Log::info('BorrowingRequestController@processReturnItem - Starting', [
                'user_id' => auth()->id(),
                'item_id' => $itemId,
                'request_data' => $request->all()
            ]);

            $user = auth()->user();
            $student = Student::where('user_id', $user->id)->first();
            if (!$student) {
                \Log::warning('BorrowingRequestController@processReturnItem - Student not found', [
                    'user_id' => $user->id
                ]);
                $dashboardRoute = $user->isStudent() ? 'students.dashboard' : 'officers.dashboard';
                return redirect()->route($dashboardRoute)->with('error', 'Data siswa tidak ditemukan.');
            }

            // Eager load commodity to prevent N+1 and to have it available for stock increment
            $item = BorrowingItem::with(['borrowing', 'commodity'])->where('id', $itemId)
                ->whereHas('borrowing', function($q) use ($student) {
                    $q->where('student_id', $student->id);
                })
                ->first();

            $indexRoute = $user->isStudent() ? 'students.borrowings.index' : 'officers.borrowings.my';

            if (!$item || $item->status !== 'approved') {
                \Log::warning('BorrowingRequestController@processReturnItem - Item not valid', [
                    'item_id' => $itemId,
                    'item_exists' => $item ? true : false,
                    'status' => $item ? $item->status : null
                ]);
                return redirect()->route($indexRoute)->with('error', 'Item tidak valid atau sudah dikembalikan.');
            }

            $request->validate([
                'condition' => 'required|string',
                'photo' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            ]);

            DB::transaction(function () use ($request, $item, $student) {
                $photoPath = null;
                if ($request->hasFile('photo')) {
                    $photoPath = $request->file('photo')->store('returns', 'public');
                }

                // Update item with return details
                $item->update([
                    'status' => 'returned',
                    'return_date_actual' => now(),
                    'return_condition' => $request->condition,
                    'return_photo' => $photoPath,
                ]);

                // Increment stock for the returned item
                if ($item->commodity) {
                    $item->commodity->increment('stock', $item->quantity);
                } else {
                    // This should not happen due to eager loading and data integrity, but as a safeguard:
                    throw new \Exception('Data barang tidak ditemukan, pengembalian dibatalkan.');
                }

                $borrowing = $item->borrowing;
                $borrowing->load('items'); // Reload to get all items with updated statuses

                // Check statuses of all items for this borrowing
                $allReturned = $borrowing->items->every(fn($i) => $i->status === 'returned');

                if ($allReturned) {
                    $borrowing->update([
                        'status' => 'returned',
                        'return_date_actual' => now(),
                    ]);

                    // Notifications for the whole borrowing being returned
                    $jurusansToNotify = $borrowing->items->pluck('commodity.jurusan')->filter()->unique()->values();
                    $admins = User::where('role', 'admin')->get();
                    $officers = User::where('role', 'officer')->whereIn('jurusan', $jurusansToNotify)->get();
                    $itemNames = $borrowing->items->pluck('commodity.name')->join(', ');
                    $message = "Semua barang untuk peminjaman oleh {$student->name} telah dikembalikan ({$itemNames}).";

                    $recipients = $admins->merge($officers);
                    $recipients->push($student->user);

                    foreach ($recipients as $recipient) {
                        $recipient->notify(new \App\Notifications\BorrowingStatusNotification('returned', $message));
                    }

                } else {
                    $borrowing->update(['status' => 'partially_returned']);
                }
            });

            \Log::info('BorrowingRequestController@processReturnItem - Success', [
                'item_id' => $itemId,
                'borrowing_id' => $item->borrowing_id
            ]);

            $showRoute = $user->isStudent() ? 'students.borrowings.show' : 'officers.borrowings.show';
            return redirect()->route($showRoute, $item->borrowing_id)->with('success', 'Barang berhasil dikembalikan!');
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@processReturnItem - Error occurred', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
                'item_id' => $itemId,
                'request_data' => $request->all(),
                'trace' => $e->getTraceAsString()
            ]);
            $indexRoute = auth()->user()->isStudent() ? 'students.borrowings.index' : 'officers.borrowings.my';
            return redirect()->route($indexRoute)->with('error', 'Terjadi kesalahan saat memproses pengembalian barang: ' . $e->getMessage());
        }
    }

    public function officerIndex()
    {
        try {
            $student = Student::where('user_id', auth()->id())->first();

            if (!$student) {
                $borrowings = new \Illuminate\Pagination\LengthAwarePaginator([], 0, 6);
                return view('officers.borrowings.my_index', compact('borrowings'));
            }

            $borrowings = Borrowing::where('student_id', $student->id)
                ->with(['commodities', 'items.commodity'])
                ->orderBy('created_at', 'desc')
                ->paginate(6)->appends(request()->query());

            $user = auth()->user();
            $user->update(['last_seen_notifications' => now()]);

            return view('officers.borrowings.my_index', compact('borrowings'));
        } catch (\Exception $e) {
            \Log::error('BorrowingRequestController@officerIndex - Error occurred', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
                'trace' => $e->getTraceAsString()
            ]);
            return redirect()->route('officers.dashboard')->with('error', 'Terjadi kesalahan saat memuat daftar peminjaman.');
        }
    }
}