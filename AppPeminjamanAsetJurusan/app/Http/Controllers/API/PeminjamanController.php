<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Borrowing;
use App\Models\BorrowingItem;
use App\Models\Commodity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use App\Notifications\BorrowingStatusNotification;

class PeminjamanController extends Controller
{
    public function index(Request $request)
    {
        Log::info('PeminjamanController::index started');
        try {
            $user = $request->user();

            if ($user->isAdmin()) {
                $borrowings = Borrowing::with('student.user', 'student.schoolClass', 'items.commodity')
                    ->orderBy('created_at', 'desc')
                    ->get();
            } elseif ($user->isOfficer()) {
                $query = Borrowing::with('student.user', 'student.schoolClass', 'items.commodity')
                    ->whereHas('items.commodity', function($q) use ($user) {
                        $q->where('jurusan', $user->jurusan);
                    });
                $borrowings = $query->orderBy('created_at', 'desc')->get();
            } else {
                // Student
                $borrowings = Borrowing::with('student.user', 'student.schoolClass', 'items.commodity')
                    ->where('student_id', $user->student->id)
                    ->orderBy('created_at', 'desc')
                    ->get();
            }

            Log::info('PeminjamanController::index ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowings retrieved successfully',
                'data' => $borrowings
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::index error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::index ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving borrowings'
            ], 500);
        }
    }

    public function getPending(Request $request)
    {
        Log::info('PeminjamanController::getPending started');
        try {
            $user = $request->user();

            if ($user->isAdmin()) {
                $borrowings = Borrowing::with('student.user', 'student.schoolClass', 'items.commodity')
                    ->where('status', 'pending')
                    ->orderBy('created_at', 'desc')
                    ->get();
            } elseif ($user->isOfficer()) {
                $borrowings = Borrowing::with('student.user', 'student.schoolClass', 'items.commodity')
                    ->where('status', 'pending')
                    ->whereHas('items.commodity', function($q) use ($user) {
                        $q->where('jurusan', $user->jurusan);
                    })
                    ->orderBy('created_at', 'desc')
                    ->get();
            } else {
                $borrowings = Borrowing::with('student.user', 'student.schoolClass', 'items.commodity')
                    ->where('status', 'pending')
                    ->where('student_id', $user->student->id)
                    ->orderBy('created_at', 'desc')
                    ->get();
            }

            Log::info('PeminjamanController::getPending ended');
            return response()->json([
                'success' => true,
                'message' => 'Pending borrowings retrieved successfully',
                'data' => $borrowings
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::getPending error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::getPending ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving pending borrowings'
            ], 500);
        }
    }

    public function updateStatus(Request $request)
    {
        Log::info('PeminjamanController::updateStatus started');
        try {
            $validator = Validator::make($request->all(), [
                'borrowing_id' => 'required|exists:borrowings,id',
                'status' => 'required|in:approved,rejected',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();
            $borrowing = Borrowing::find($request->borrowing_id);

            // Check permissions
            if ($user->isOfficer()) {
                // Officer can only update borrowings for their jurusan
                $hasPermission = $borrowing->items->contains(function($item) use ($user) {
                    return $item->commodity->jurusan === $user->jurusan;
                });
                if (!$hasPermission) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Unauthorized to update this borrowing'
                    ], 403);
                }
            }

            $borrowing->status = $request->status;
            $borrowing->save();

            Log::info('PeminjamanController::updateStatus ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowing status updated successfully',
                'data' => $borrowing->load('student.user', 'student.schoolClass', 'items.commodity')
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::updateStatus error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::updateStatus ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while updating borrowing status'
            ], 500);
        }
    }

    public function store(Request $request)
    {
        Log::info('PeminjamanController::store started');
        try {
            Log::info('PeminjamanController::store request received', [
                'request_data' => $request->all(),
                'user_id' => $request->user() ? $request->user()->id : null,
            ]);

            $validator = Validator::make($request->all(), [
                'borrow_date' => 'required|date|after_or_equal:today',
                'return_date' => 'required|date|after:borrow_date',
                'tujuan' => 'required|string|max:255',
                'items' => 'required|array|min:1',
                'items.*.commodity_id' => 'required|exists:commodities,id',
                'items.*.quantity' => 'required|integer|min:1',
            ]);

            if ($validator->fails()) {
                Log::warning('PeminjamanController::store validation failed', [
                    'user_id' => $request->user() ? $request->user()->id : null,
                    'errors' => $validator->errors()->toArray(),
                    'request_data' => $request->all(),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();

            Log::info('PeminjamanController::store called', [
                'user_id' => $user->id,
                'user_email' => $user->email,
                'user_role' => $user->role,
                'has_student' => $user->student ? true : false,
                'student_id' => $user->student ? $user->student->id : null,
            ]);

            // Check if student has any active borrowings
            $activeBorrowings = Borrowing::where('student_id', $user->student->id)
                ->whereIn('status', ['pending', 'approved'])
                ->count();

            if ($activeBorrowings > 0) {
                Log::warning('PeminjamanController::store active borrowings check failed', [
                    'user_id' => $user->id,
                    'student_id' => $user->student->id,
                    'active_borrowings_count' => $activeBorrowings,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'You have active borrowings. Please return them first.'
                ], 400);
            }

            // Check item availability
            foreach ($request->items as $item) {
                $commodity = Commodity::find($item['commodity_id']);
                if (!$commodity) {
                    Log::error('PeminjamanController::store commodity not found', [
                        'commodity_id' => $item['commodity_id'],
                        'user_id' => $user->id,
                    ]);
                    return response()->json([
                        'success' => false,
                        'message' => 'Commodity not found'
                    ], 404);
                }
                if ($commodity->stock < $item['quantity']) {
                    Log::warning('PeminjamanController::store insufficient stock', [
                        'commodity_id' => $item['commodity_id'],
                        'commodity_name' => $commodity->name,
                        'requested_quantity' => $item['quantity'],
                        'available_stock' => $commodity->stock,
                        'user_id' => $user->id,
                    ]);
                    return response()->json([
                        'success' => false,
                        'message' => 'Insufficient quantity for ' . $commodity->name
                    ], 400);
                }
            }

            // Create borrowing
            $borrowing = Borrowing::create([
                'student_id' => $user->student->id,
                'borrow_date' => $request->borrow_date,
                'return_date' => $request->return_date,
                'status' => 'pending',
                'tujuan' => $request->tujuan,
            ]);

            Log::info('PeminjamanController::store borrowing created', [
                'borrowing_id' => $borrowing->id,
                'user_id' => $user->id,
                'student_id' => $user->student->id,
            ]);

            // Create borrowing items
            foreach ($request->items as $item) {
                BorrowingItem::create([
                    'borrowing_id' => $borrowing->id,
                    'commodity_id' => $item['commodity_id'],
                    'quantity' => $item['quantity'],
                ]);

                // Update commodity stock
                $commodity = Commodity::find($item['commodity_id']);
                $commodity->stock -= $item['quantity'];
                $commodity->save();

                Log::info('PeminjamanController::store borrowing item created and stock updated', [
                    'borrowing_id' => $borrowing->id,
                    'commodity_id' => $item['commodity_id'],
                    'quantity' => $item['quantity'],
                    'new_stock' => $commodity->stock,
                ]);
            }

            // Clear the cart after successful borrowing creation
            $cart = \App\Models\Cart::getOrCreateForUser($user->id);
            $cart->clear();

            Log::info('PeminjamanController::store cart cleared after successful borrowing', [
                'borrowing_id' => $borrowing->id,
                'user_id' => $user->id,
                'cart_id' => $cart->id,
            ]);

            Log::info('PeminjamanController::store completed successfully', [
                'borrowing_id' => $borrowing->id,
                'user_id' => $user->id,
            ]);

            Log::info('PeminjamanController::store ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowing request created successfully',
                'data' => $borrowing->load('student.user', 'student.schoolClass', 'items.commodity')
            ], 201);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::store error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $request->user() ? $request->user()->id : null,
                'request_data' => $request->all(),
            ]);
            Log::error('PeminjamanController::store ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while creating borrowing request'
            ], 500);
        }
    }

    public function show(Request $request, $id)
    {
        Log::info('PeminjamanController::show started');
        try {
            $user = $request->user();
            $borrowing = Borrowing::with('student.user', 'student.schoolClass', 'items.commodity');

            if ($user->isOfficer()) {
                $borrowing->whereHas('items.commodity', function($q) use ($user) {
                    $q->where('jurusan', $user->jurusan);
                });
            } elseif (!$user->isAdmin()) {
                $borrowing->where('student_id', $user->student->id);
            }

            $borrowing = $borrowing->find($id);

            if (!$borrowing) {
                Log::info('PeminjamanController::show ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing not found'
                ], 404);
            }

            Log::info('PeminjamanController::show ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowing retrieved successfully',
                'data' => $borrowing
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::show error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::show ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving borrowing'
            ], 500);
        }
    }

    public function returnBorrowing(Request $request, $id)
    {
        Log::info('PeminjamanController::returnBorrowing started');
        try {
            $validator = Validator::make($request->all(), [
                'return_condition' => 'required|string',
                'return_photo' => 'nullable|file|max:10240',
                'items' => 'nullable|array',
                'items.*' => 'exists:borrowing_items,id',
            ]);

            if ($validator->fails()) {
                Log::info('PeminjamanController::returnBorrowing ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();
            $borrowing = Borrowing::with('items.commodity')->find($id);

            if (!$borrowing) {
                Log::info('PeminjamanController::returnBorrowing ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing not found'
                ], 404);
            }

            // Check if user owns this borrowing or is admin
            if (!$user->isAdmin() && $borrowing->student_id !== $user->student->id) {
                Log::info('PeminjamanController::returnBorrowing ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            // Check if borrowing is already fully returned
            $remainingApproved = $borrowing->items->where('status', 'approved')->count();
            if ($borrowing->status === 'returned' || ($borrowing->status === 'partially_returned' && $remainingApproved === 0 && $borrowing->return_condition)) {
                Log::info('PeminjamanController::returnBorrowing ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing already returned'
                ], 400);
            }

            // Check if borrowing is approved or partially approved
            Log::info('Return borrowing attempt', [
                'borrowing_id' => $id,
                'borrowing_status' => $borrowing->status,
                'user_id' => $user->id,
                'user_role' => $user->role
            ]);

            if ($borrowing->status !== 'approved' && $borrowing->status !== 'partially_approved' && $borrowing->status !== 'partially_returned' && $borrowing->status !== 'returned') {
                Log::warning('Return borrowing failed: invalid status', [
                    'borrowing_id' => $id,
                    'status' => $borrowing->status
                ]);
                Log::info('PeminjamanController::returnBorrowing ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing is not approved'
                ], 400);
            }

            // Determine items to return
            $itemIds = $request->has('items') ? $request->items : $borrowing->items->where('status', 'approved')->pluck('id')->toArray();

            // Validate items are approved and belong to this borrowing
            $validItems = $borrowing->items->whereIn('id', $itemIds)->where('status', 'approved');
            $itemIds = $validItems->pluck('id')->toArray();
            if ($validItems->isEmpty()) {
                Log::info('PeminjamanController::returnBorrowing ended');
                return response()->json([
                    'success' => false,
                    'message' => 'No valid items to return'
                ], 400);
            }
            if ($validItems->count() !== count($itemIds)) {
                Log::info('PeminjamanController::returnBorrowing ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid items selected for return'
                ], 400);
            }

            // Handle photo upload
            $photoPath = null;
            if ($request->hasFile('return_photo')) {
                $photoPath = $request->file('return_photo')->store('returns', 'public');
            }

            // Update selected item statuses to returned and return items to inventory (only for approved items)
            foreach ($validItems as $item) {
                $item->status = 'returned';
                $item->save();

                // Only return stock to inventory if the item was approved (not rejected)
                if ($item->getOriginal('status') == 'approved') {
                    $commodity = $item->commodity;
                    $commodity->stock += $item->quantity;
                    $commodity->save();
                }
            }

            // Update borrowing status based on returned items
            $this->updateBorrowingStatusAfterReturn($borrowing);

            // Set return condition and photo only if fully returned
            if ($borrowing->status === 'returned') {
                $borrowing->return_condition = $request->return_condition;
                $borrowing->return_photo = $photoPath;
                $borrowing->save();
            }

            Log::info('PeminjamanController::returnBorrowing ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowing returned successfully',
                'data' => $borrowing->load('student.user', 'student.schoolClass', 'items.commodity')
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::returnBorrowing error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::returnBorrowing ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while returning borrowing'
            ], 500);
        }
    }

    public function approve(Request $request, $id)
    {
        Log::info('PeminjamanController::approve started');
        try {
            $user = $request->user();
            $borrowing = Borrowing::with('items.commodity')->find($id);

            if (!$borrowing) {
                Log::info('PeminjamanController::approve ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing not found'
                ], 404);
            }

            // Determine items to approve
            $itemIds = $request->has('items') ? $request->items : $borrowing->items->where('status', 'pending')->pluck('id')->toArray();

            // Validate items are pending and belong to this borrowing
            $validItems = $borrowing->items->whereIn('id', $itemIds)->where('status', 'pending');

            if ($validItems->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'No valid items to approve'
                ], 400);
            }

            // Approve selected items
            foreach ($validItems as $item) {
                if ($user->isOfficer() && $user->jurusan && strtolower($item->commodity->jurusan) !== strtolower($user->jurusan)) {
                    continue; // Skip items not belonging to the officer's jurusan
                }
                $item->status = 'approved';
                $item->save();
            }

            // Update overall borrowing status
            $this->updateBorrowingStatus($borrowing);

            // Send notification to the borrower
            $student = $borrowing->student;
            if ($student && $student->user) {
                $student->user->notify(new BorrowingStatusNotification('approved', 'Peminjaman Anda telah disetujui.', $validItems));
            }

            Log::info('PeminjamanController::approve ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowing items approved successfully',
                'data' => $borrowing->load('student.user', 'student.schoolClass', 'items.commodity')
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::approve error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::approve ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while approving borrowing'
            ], 500);
        }
    }

    public function reject(Request $request, $id)
    {
        Log::info('PeminjamanController::reject started');
        try {
            $user = $request->user();
            $borrowing = Borrowing::with('items.commodity')->find($id);

            if (!$borrowing) {
                Log::info('PeminjamanController::reject ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing not found'
                ], 404);
            }

            // Determine items to reject
            $itemIds = $request->has('items') ? $request->items : $borrowing->items->where('status', 'pending')->pluck('id')->toArray();

            // Validate items are pending and belong to this borrowing
            $validItems = $borrowing->items->whereIn('id', $itemIds)->where('status', 'pending');

            if ($validItems->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'No valid items to reject'
                ], 400);
            }

            // Reject selected items and return quantities to inventory
            foreach ($validItems as $item) {
                if ($user->isOfficer() && $user->jurusan && strtolower($item->commodity->jurusan) !== strtolower($user->jurusan)) {
                    continue; // Skip items not belonging to the officer's jurusan
                }
                $item->status = 'rejected';
                $item->save();

                $commodity = $item->commodity;
                $commodity->stock += $item->quantity;
                $commodity->save();
            }

            // Update overall borrowing status
            $this->updateBorrowingStatus($borrowing);

            // Send notification to the borrower
            $student = $borrowing->student;
            if ($student && $student->user) {
                $itemNames = $validItems->pluck('commodity.name')->join(', ');
                $message = "Maaf, peminjaman Anda untuk barang: {$itemNames} ditolak.";
                $student->user->notify(new BorrowingStatusNotification('rejected', $message));
            }

            Log::info('PeminjamanController::reject ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowing items rejected successfully',
                'data' => $borrowing->load('student.user', 'student.schoolClass', 'items.commodity')
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::reject error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::reject ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while rejecting borrowing'
            ], 500);
        }
    }

    public function adminReturn(Request $request, $id)
    {
        Log::info('PeminjamanController::adminReturn started');
        try {
            $validator = Validator::make($request->all(), [
                'return_condition' => 'nullable|string',
                'return_photo' => 'nullable|file|max:10240',
                'items' => 'nullable|array',
                'items.*' => 'exists:borrowing_items,id',
            ]);

            if ($validator->fails()) {
                Log::info('PeminjamanController::adminReturn ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $borrowing = Borrowing::with('items.commodity')->find($id);

            if (!$borrowing) {
                Log::info('PeminjamanController::adminReturn ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing not found'
                ], 404);
            }

            // Check if borrowing is already fully returned
            $remainingApproved = $borrowing->items->where('status', 'approved')->count();
            if ($borrowing->status === 'returned' || ($borrowing->status === 'partially_returned' && $remainingApproved === 0 && $borrowing->return_condition)) {
                Log::info('PeminjamanController::adminReturn ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing already returned'
                ], 400);
            }

            // Check if borrowing is approved or partially approved
            if ($borrowing->status !== 'approved' && $borrowing->status !== 'partially_approved' && $borrowing->status !== 'partially_returned' && $borrowing->status !== 'returned') {
                Log::info('PeminjamanController::adminReturn ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing is not approved'
                ], 400);
            }

            // Determine items to return - for admin return, return all approved items that are not already returned
            $itemIds = $request->has('items') ? $request->items : $borrowing->items->where('status', 'approved')->pluck('id')->toArray();

            // Validate items belong to this borrowing and are approved
            $validItems = $borrowing->items->whereIn('id', $itemIds)->where('status', 'approved');
            $itemIds = $validItems->pluck('id')->toArray();
            if ($validItems->isEmpty()) {
                Log::info('PeminjamanController::adminReturn ended');
                return response()->json([
                    'success' => false,
                    'message' => 'No valid items to return'
                ], 400);
            }
            if ($validItems->count() !== count($itemIds)) {
                Log::info('PeminjamanController::adminReturn ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid items selected for return'
                ], 400);
            }

            // Handle photo upload
            $photoPath = null;
            if ($request->hasFile('return_photo')) {
                $photoPath = $request->file('return_photo')->store('returns', 'public');
            }

            // Update selected approved item statuses to returned and return items to inventory
            foreach ($validItems as $item) {
                $item->status = 'returned';
                $item->save();

                $commodity = $item->commodity;
                $commodity->stock += $item->quantity;
                $commodity->save();
            }

            // Update borrowing status based on returned items
            $this->updateBorrowingStatusAfterReturn($borrowing);

            // Set return condition and photo only if fully returned
            if ($borrowing->status === 'returned') {
                $borrowing->return_condition = $request->return_condition;
                $borrowing->return_photo = $photoPath;
                $borrowing->save();
            }

            Log::info('PeminjamanController::adminReturn ended');
            return response()->json([
                'success' => true,
                'message' => 'Borrowing returned successfully',
                'data' => $borrowing->load('student.user', 'student.schoolClass', 'items.commodity')
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::adminReturn error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('PeminjamanController::adminReturn ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while returning borrowing'
            ], 500);
        }
    }

    private function updateBorrowingStatus(Borrowing $borrowing)
    {
        $borrowing->load('items');
        $items = $borrowing->items;
        $approvedCount = $items->where('status', 'approved')->count();
        $rejectedCount = $items->where('status', 'rejected')->count();
        $totalItems = $items->count();

        if ($approvedCount === $totalItems) {
            $borrowing->status = 'approved';
        } elseif ($rejectedCount === $totalItems) {
            $borrowing->status = 'rejected';
        } else {
            $borrowing->status = 'partially_approved';
        }

        $borrowing->save();
    }

    public function returnItem(Request $request, $borrowingId, $itemId)
    {
        Log::info('PeminjamanController::returnItem started', [
            'borrowing_id' => $borrowingId,
            'item_id' => $itemId,
            'user_id' => $request->user() ? $request->user()->id : null,
        ]);

        try {
            $validator = Validator::make($request->all(), [
                'return_condition' => 'required|string',
                'return_photo' => 'nullable|file|max:10240',
            ]);

            if ($validator->fails()) {
                Log::warning('PeminjamanController::returnItem validation failed', [
                    'borrowing_id' => $borrowingId,
                    'item_id' => $itemId,
                    'errors' => $validator->errors()->toArray(),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();
            $borrowing = Borrowing::with('items.commodity')->find($borrowingId);

            if (!$borrowing) {
                Log::warning('PeminjamanController::returnItem borrowing not found', [
                    'borrowing_id' => $borrowingId,
                    'item_id' => $itemId,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Borrowing not found'
                ], 404);
            }

            // Check if user owns this borrowing or is admin
            if (!$user->isAdmin() && $borrowing->student_id !== $user->student->id) {
                Log::warning('PeminjamanController::returnItem unauthorized access', [
                    'borrowing_id' => $borrowingId,
                    'item_id' => $itemId,
                    'user_id' => $user->id,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            // Find the specific item
            $item = $borrowing->items->find($itemId);
            if (!$item) {
                Log::warning('PeminjamanController::returnItem item not found in borrowing', [
                    'borrowing_id' => $borrowingId,
                    'item_id' => $itemId,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Item not found in this borrowing'
                ], 404);
            }

            // Check if item is approved
            if ($item->status !== 'approved') {
                Log::warning('PeminjamanController::returnItem item not approved', [
                    'borrowing_id' => $borrowingId,
                    'item_id' => $itemId,
                    'item_status' => $item->status,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Item is not approved for return'
                ], 400);
            }

            // Handle photo upload
            $photoPath = null;
            if ($request->hasFile('return_photo')) {
                $photoPath = $request->file('return_photo')->store('returns', 'public');
                Log::info('PeminjamanController::returnItem photo uploaded', [
                    'borrowing_id' => $borrowingId,
                    'item_id' => $itemId,
                    'photo_path' => $photoPath,
                ]);
            }

            // Update item status to returned
            $item->status = 'returned';
            $item->save();

            // Return item to inventory
            $commodity = $item->commodity;
            $commodity->stock += $item->quantity;
            $commodity->save();

            Log::info('PeminjamanController::returnItem item returned successfully', [
                'borrowing_id' => $borrowingId,
                'item_id' => $itemId,
                'commodity_id' => $commodity->id,
                'quantity_returned' => $item->quantity,
                'new_stock' => $commodity->stock,
            ]);

            // Update borrowing status based on returned items
            $this->updateBorrowingStatusAfterReturn($borrowing);

            // Set return condition and photo only if fully returned
            if ($borrowing->status === 'returned') {
                $borrowing->return_condition = $request->return_condition;
                $borrowing->return_photo = $photoPath;
                $borrowing->save();
                Log::info('PeminjamanController::returnItem borrowing fully returned', [
                    'borrowing_id' => $borrowingId,
                ]);
            }

            Log::info('PeminjamanController::returnItem ended successfully', [
                'borrowing_id' => $borrowingId,
                'item_id' => $itemId,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Item returned successfully',
                'data' => $borrowing->load('student.user', 'student.schoolClass', 'items.commodity')
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::returnItem error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'borrowing_id' => $borrowingId,
                'item_id' => $itemId,
                'user_id' => $request->user() ? $request->user()->id : null,
            ]);
            Log::error('PeminjamanController::returnItem ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while returning item'
            ], 500);
        }
    }

    private function updateBorrowingStatusAfterReturn(Borrowing $borrowing)
    {
        $borrowing->load('items');
        $items = $borrowing->items;
        $returnedCount = $items->where('status', 'returned')->count();
        $rejectedCount = $items->where('status', 'rejected')->count();
        $totalReturnable = $items->count() - $rejectedCount;

        if ($returnedCount === $totalReturnable && $totalReturnable > 0) {
            $borrowing->status = 'returned';
        } elseif ($returnedCount > 0) {
            $borrowing->status = 'partially_returned';
        } else {
            // If no items were returned, but return was attempted, perhaps keep as is or set to something, but shouldn't happen
            $borrowing->status = $borrowing->status; // keep previous status
        }

        $borrowing->save();
    }

    public function getCart(Request $request)
    {
        Log::info('PeminjamanController::getCart started');
        try {
            $user = $request->user();

            if (!$user->isStudent()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Only students can access cart'
                ], 403);
            }

            // Get or create cart for the user
            $cart = \App\Models\Cart::getOrCreateForUser($user->id);

            // Get cart items with commodity information
            $cartItems = $cart->items()->with('commodity')->get()->map(function ($item) {
                return [
                    'id' => $item->id,
                    'commodity_id' => $item->commodity_id,
                    'quantity' => $item->quantity,
                    'commodity' => $item->commodity,
                    'created_at' => $item->created_at,
                    'updated_at' => $item->updated_at,
                ];
            });

            Log::info('PeminjamanController::getCart ended');
            return response()->json([
                'success' => true,
                'message' => 'Cart retrieved successfully',
                'data' => $cartItems
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::getCart error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving cart'
            ], 500);
        }
    }

    public function saveCart(Request $request)
    {
        Log::info('PeminjamanController::saveCart started', [
            'request_data' => $request->all(),
            'user_id' => $request->user() ? $request->user()->id : null,
            'headers' => $request->headers->all(),
        ]);

        try {
            $user = $request->user();

            if (!$user) {
                Log::warning('PeminjamanController::saveCart no authenticated user');
                return response()->json([
                    'success' => false,
                    'message' => 'Authentication required'
                ], 401);
            }

            Log::info('PeminjamanController::saveCart user check', [
                'user_id' => $user->id,
                'user_role' => $user->role,
                'is_student' => $user->isStudent,
                'has_student_relation' => $user->student ? true : false,
            ]);

            if (!$user->isStudent()) {
                Log::warning('PeminjamanController::saveCart user is not student', [
                    'user_id' => $user->id,
                    'user_role' => $user->role,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Only students can save cart'
                ], 403);
            }

            $validator = Validator::make($request->all(), [
                'items' => 'required|array',
                'items.*.commodity_id' => 'required|exists:commodities,id',
                'items.*.quantity' => 'required|integer|min:1',
            ]);

            if ($validator->fails()) {
                Log::warning('PeminjamanController::saveCart validation failed', [
                    'user_id' => $user->id,
                    'errors' => $validator->errors()->toArray(),
                    'request_data' => $request->all(),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            Log::info('PeminjamanController::saveCart validation passed', [
                'user_id' => $user->id,
                'items_count' => count($request->items),
            ]);

            // Get or create cart for the user
            $cart = \App\Models\Cart::getOrCreateForUser($user->id);

            // Clear existing cart items
            $cart->clear();

            // Add new items to cart
            foreach ($request->items as $itemData) {
                \App\Models\CartItem::create([
                    'cart_id' => $cart->id,
                    'commodity_id' => $itemData['commodity_id'],
                    'quantity' => $itemData['quantity'],
                ]);
            }

            Log::info('PeminjamanController::saveCart cart saved successfully', [
                'user_id' => $user->id,
                'cart_id' => $cart->id,
                'items_count' => count($request->items),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Cart saved successfully'
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::saveCart error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $request->user() ? $request->user()->id : null,
                'request_data' => $request->all(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while saving cart'
            ], 500);
        }
    }

    public function updateCartItem(Request $request)
    {
        Log::info('PeminjamanController::updateCartItem started', [
            'request_data' => $request->all(),
            'user_id' => $request->user() ? $request->user()->id : null,
        ]);

        try {
            $user = $request->user();

            if (!$user) {
                Log::warning('PeminjamanController::updateCartItem no authenticated user');
                return response()->json([
                    'success' => false,
                    'message' => 'Authentication required'
                ], 401);
            }

            if (!$user->isStudent()) {
                Log::warning('PeminjamanController::updateCartItem user is not student', [
                    'user_id' => $user->id,
                    'user_role' => $user->role,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Only students can update cart'
                ], 403);
            }

            $validator = Validator::make($request->all(), [
                'commodity_id' => 'required|exists:commodities,id',
                'quantity' => 'required|integer|min:0',
            ]);

            if ($validator->fails()) {
                Log::warning('PeminjamanController::updateCartItem validation failed', [
                    'user_id' => $user->id,
                    'errors' => $validator->errors()->toArray(),
                    'request_data' => $request->all(),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Get or create cart for the user
            $cart = \App\Models\Cart::getOrCreateForUser($user->id);

            if ($request->quantity == 0) {
                // Remove item from cart
                $cart->items()->where('commodity_id', $request->commodity_id)->delete();
                Log::info('PeminjamanController::updateCartItem item removed from cart', [
                    'user_id' => $user->id,
                    'commodity_id' => $request->commodity_id,
                ]);
            } else {
                // Update or create cart item
                $cartItem = $cart->items()->where('commodity_id', $request->commodity_id)->first();

                if ($cartItem) {
                    $cartItem->quantity = $request->quantity;
                    $cartItem->save();
                    Log::info('PeminjamanController::updateCartItem item updated in cart', [
                        'user_id' => $user->id,
                        'commodity_id' => $request->commodity_id,
                        'quantity' => $request->quantity,
                    ]);
                } else {
                    \App\Models\CartItem::create([
                        'cart_id' => $cart->id,
                        'commodity_id' => $request->commodity_id,
                        'quantity' => $request->quantity,
                    ]);
                    Log::info('PeminjamanController::updateCartItem item added to cart', [
                        'user_id' => $user->id,
                        'commodity_id' => $request->commodity_id,
                        'quantity' => $request->quantity,
                    ]);
                }
            }

            Log::info('PeminjamanController::updateCartItem completed successfully', [
                'user_id' => $user->id,
                'commodity_id' => $request->commodity_id,
                'quantity' => $request->quantity,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Cart item updated successfully'
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::updateCartItem error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $request->user() ? $request->user()->id : null,
                'request_data' => $request->all(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while updating cart item'
            ], 500);
        }
    }

    public function clearCart(Request $request)
    {
        Log::info('PeminjamanController::clearCart started', [
            'user_id' => $request->user() ? $request->user()->id : null,
        ]);

        try {
            $user = $request->user();

            if (!$user) {
                Log::warning('PeminjamanController::clearCart no authenticated user');
                return response()->json([
                    'success' => false,
                    'message' => 'Authentication required'
                ], 401);
            }

            if (!$user->isStudent()) {
                Log::warning('PeminjamanController::clearCart user is not student', [
                    'user_id' => $user->id,
                    'user_role' => $user->role,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Only students can clear cart'
                ], 403);
            }

            // Get or create cart for the user
            $cart = \App\Models\Cart::getOrCreateForUser($user->id);

            // Clear all cart items
            $cart->clear();

            Log::info('PeminjamanController::clearCart completed successfully', [
                'user_id' => $user->id,
                'cart_id' => $cart->id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Cart cleared successfully'
            ]);
        } catch (\Exception $e) {
            Log::error('PeminjamanController::clearCart error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $request->user() ? $request->user()->id : null,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while clearing cart'
            ], 500);
        }
    }
}
