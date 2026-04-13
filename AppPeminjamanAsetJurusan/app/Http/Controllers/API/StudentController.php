<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Borrowing;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class StudentController extends Controller
{
    public function dashboardStats(Request $request)
    {
        \Log::info('StudentController::dashboardStats started');
        try {
            $user = Auth::user();
            $student = $user->student;

            if (!$student) {
                Log::error('StudentController::dashboardStats - Student record not found for user', [
                    'user_id' => $user->id,
                    'user_email' => $user->email
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Student record not found'
                ], 404);
            }

            // My active borrowings count
            $myActiveBorrowingsCount = $student->borrowings()
                ->where('status', 'approved')
                ->where('return_date', '>', now())
                ->count();

            // Pending borrowings count
            $pendingBorrowingsCount = $student->borrowings()
                ->where('status', 'pending')
                ->count();

            // Approved or overdue borrowings count
            $approvedOrOverdueBorrowingsCount = $student->borrowings()
                ->whereIn('status', ['approved', 'overdue'])
                ->count();

            // Total available assets
            $totalAvailableAssets = DB::table('commodities')
                ->where('condition', 'available')
                ->count();

            \Log::info('StudentController::dashboardStats ended');
            return response()->json([
                'success' => true,
                'message' => 'Student dashboard statistics retrieved successfully',
                'data' => [
                    'my_active_borrowings_count' => $myActiveBorrowingsCount,
                    'pending_borrowings_count' => $pendingBorrowingsCount,
                    'approved_or_overdue_borrowings_count' => $approvedOrOverdueBorrowingsCount,
                    'total_available_assets' => $totalAvailableAssets,
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('StudentController::dashboardStats error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching dashboard stats'
            ], 500);
        }
    }

    public function activeBorrowings(Request $request)
    {
        Log::info('StudentController::activeBorrowings started');
        try {
            $user = Auth::user();
            $student = $user->student;

            if (!$student) {
                Log::info('StudentController::activeBorrowings ended');
                return response()->json(['data' => []], 404);
            }

            $borrowings = $student->borrowings()->with('items.commodity')
                ->where('status', 'approved')
                ->where('return_date', '>', now())
                ->get();

            $formattedBorrowings = $borrowings->map(function ($borrowing) {
                return [
                    'id' => $borrowing->id,
                    'borrow_date' => $borrowing->borrow_date ? $borrowing->borrow_date->format('Y-m-d') : null,
                    'return_date' => $borrowing->return_date ? $borrowing->return_date->format('Y-m-d') : null,
                    'tujuan' => $borrowing->tujuan,
                    'items' => $borrowing->items->map(function ($item) {
                        return [
                            'asset_name' => $item->commodity->name,
                            'asset_description' => $item->commodity->description,
                            'quantity' => $item->quantity
                        ];
                    })
                ];
            });

            Log::info('StudentController::activeBorrowings ended');
            return response()->json(['data' => $formattedBorrowings]);
        } catch (\Exception $e) {
            Log::error('StudentController::activeBorrowings error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching active borrowings'
            ], 500);
        }
    }

    public function recentRequests(Request $request)
    {
        Log::info('StudentController::recentRequests started');
        try {
            $user = Auth::user();
            $student = $user->student;

            if (!$student) {
                Log::info('StudentController::recentRequests ended');
                return response()->json(['data' => []], 404);
            }

            $borrowings = $student->borrowings()->with('items.commodity')
                ->where('created_at', '>', now()->subDays(7))
                ->get();

            $formattedBorrowings = $borrowings->map(function ($borrowing) {
                return [
                    'id' => $borrowing->id,
                    'borrow_date' => $borrowing->borrow_date ? $borrowing->borrow_date->format('Y-m-d') : null,
                    'return_date' => $borrowing->return_date ? $borrowing->return_date->format('Y-m-d') : null,
                    'tujuan' => $borrowing->tujuan,
                    'items' => $borrowing->items->map(function ($item) {
                        return [
                            'asset_name' => $item->commodity->name,
                            'asset_description' => $item->commodity->description,
                            'quantity' => $item->quantity
                        ];
                    })
                ];
            });

            Log::info('StudentController::recentRequests ended');
            return response()->json(['data' => $formattedBorrowings]);
        } catch (\Exception $e) {
            Log::error('StudentController::recentRequests error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching recent requests'
            ], 500);
        }
    }

    public function borrowingHistory(Request $request)
    {
        Log::info('StudentController::borrowingHistory started');
        try {
            $user = Auth::user();
            $student = $user->student;

            if (!$student) {
                Log::error('StudentController::borrowingHistory - Student record not found for user', [
                    'user_id' => $user->id,
                    'user_email' => $user->email
                ]);
                Log::info('StudentController::borrowingHistory ended');
                return response()->json(['data' => []], 404);
            }

            $borrowings = $student->borrowings()->with('items.commodity')->get();

            $formattedBorrowings = $borrowings->map(function ($borrowing) {
                return [
                    'id' => $borrowing->id,
                    'status' => $borrowing->status,
                    'borrow_date' => $borrowing->borrow_date ? $borrowing->borrow_date->format('Y-m-d') : null,
                    'return_date' => $borrowing->return_date ? $borrowing->return_date->format('Y-m-d') : null,
                    'tujuan' => $borrowing->tujuan,
                    'items' => $borrowing->items->map(function ($item) {
                        return [
                            'id' => $item->id,
                            'commodity' => [
                                'name' => $item->commodity->name,
                                'code' => $item->commodity->code,
                                'photo' => $item->commodity->photo ? url('storage/' . ltrim($item->commodity->photo, '/')) : null,
                            ],
                            'quantity' => $item->quantity,
                            'status' => $item->status
                        ];
                    })
                ];
            });

            Log::info('StudentController::borrowingHistory ended');
            return response()->json(['data' => $formattedBorrowings]);
        } catch (\Exception $e) {
            Log::error('StudentController::borrowingHistory error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching borrowing history'
            ], 500);
        }
    }

    public function showBorrowing($id)
    {
        Log::info('StudentController::showBorrowing started');
        try {
            $user = Auth::user();
            $student = $user->student;

            if (!$student) {
                Log::info('StudentController::showBorrowing ended');
                return response()->json(['data' => null], 404);
            }

            $borrowing = $student->borrowings()->with('items.commodity')->find($id);

            if (!$borrowing) {
                Log::info('StudentController::showBorrowing ended');
                return response()->json(['data' => null], 404);
            }

            $formattedBorrowing = [
                'id' => $borrowing->id,
                'status' => $borrowing->status,
                'borrow_date' => $borrowing->borrow_date ? $borrowing->borrow_date->format('Y-m-d') : null,
                'return_date' => $borrowing->return_date ? $borrowing->return_date->format('Y-m-d') : null,
                'tujuan' => $borrowing->tujuan,
                'items' => $borrowing->items->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'commodity' => [
                            'name' => $item->commodity->name,
                            'code' => $item->commodity->code,
                            'photo' => $item->commodity->photo ? url('storage/' . ltrim($item->commodity->photo, '/')) : null,
                        ],
                        'quantity' => $item->quantity,
                        'status' => $item->status
                    ];
                })
            ];

            Log::info('StudentController::showBorrowing ended');
            return response()->json(['data' => $formattedBorrowing]);
        } catch (\Exception $e) {
            Log::error('StudentController::showBorrowing error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching borrowing details'
            ], 500);
        }
    }
}
