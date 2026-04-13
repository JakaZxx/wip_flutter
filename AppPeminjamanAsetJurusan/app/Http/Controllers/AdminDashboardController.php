<?php

namespace App\Http\Controllers;

use App\Models\Commodity;
use App\Models\Borrowing;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class AdminDashboardController extends Controller
{
    public function index()
    {
        // Data for Admin Dashboard
        $totalUsers = User::count();
        $totalAssets = Commodity::count();
        $pendingUsersCount = User::where('approval_status', 'pending')->count();
        $totalBorrowings = Borrowing::count();

        // Recent users needing approval
        $recentUsers = User::where('approval_status', 'pending')->latest()->take(5)->get();

        // 1. User Growth - total users in last 6 months
        $userGrowth = User::select(
            DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month"),
            DB::raw('COUNT(*) as count')
        )
        ->where('created_at', '>=', Carbon::now()->subMonths(6))
        ->groupBy('month')
        ->orderBy('month')
        ->get();

        // Prepare user growth data for chart
        $userGrowthLabels = [];
        $userGrowthData = [];
        $months = collect();
        for ($i = 5; $i >= 0; $i--) {
            $months->push(Carbon::now()->subMonths($i)->format('Y-m'));
        }
        foreach ($months as $month) {
            $userGrowthLabels[] = Carbon::createFromFormat('Y-m', $month)->format('M');
            $found = $userGrowth->firstWhere('month', $month);
            $userGrowthData[] = $found ? $found->count : 0;
        }

        // 2. Asset Distribution - total vs available by category (name)
        $assetDistributionTotal = Commodity::select('name', DB::raw('COUNT(*) as total'))
            ->groupBy('name')
            ->get();

        $assetDistributionAvailable = Commodity::select('name', DB::raw('COUNT(*) as available'))
            ->where('condition', 'available')
            ->groupBy('name')
            ->get();

        // Map available counts by name for easy lookup
        $availableMap = $assetDistributionAvailable->keyBy('name');

        $assetDistributionLabels = [];
        $assetDistributionTotalData = [];
        $assetDistributionAvailableData = [];

        foreach ($assetDistributionTotal as $item) {
            $assetDistributionLabels[] = $item->name;
            $assetDistributionTotalData[] = $item->total;
            $assetDistributionAvailableData[] = $availableMap->has($item->name) ? $availableMap[$item->name]->available : 0;
        }

        // 3. Borrowing Trend - borrowed vs returned in last 6 weeks
        $borrowedTrend = Borrowing::select(
            DB::raw("DATE_FORMAT(borrow_date, '%Y-%u') as week"),
            DB::raw('COUNT(*) as count')
        )
        ->where('borrow_date', '>=', Carbon::now()->subWeeks(6))
        ->groupBy('week')
        ->orderBy('week')
        ->get();

        $returnedTrend = Borrowing::select(
            DB::raw("DATE_FORMAT(return_date, '%Y-%u') as week"),
            DB::raw('COUNT(*) as count')
        )
        ->where('return_date', '>=', Carbon::now()->subWeeks(6))
        ->groupBy('week')
        ->orderBy('week')
        ->get();

        // Prepare borrowing trend data for chart
        $borrowTrendLabels = [];
        $borrowedData = [];
        $returnedData = [];
        $weeks = collect();
        for ($i = 5; $i >= 0; $i--) {
            $weeks->push(Carbon::now()->subWeeks($i)->format('Y-W'));
        }
        foreach ($weeks as $week) {
            $borrowTrendLabels[] = 'W' . explode('-', $week)[1];
            $foundBorrowed = $borrowedTrend->firstWhere('week', $week);
            $foundReturned = $returnedTrend->firstWhere('week', $week);
            $borrowedData[] = $foundBorrowed ? $foundBorrowed->count : 0;
            $returnedData[] = $foundReturned ? $foundReturned->count : 0;
        }

        // 4. Asset Status - summary of conditions
        $assetStatusCounts = Commodity::select('condition', DB::raw('COUNT(*) as count'))
            ->groupBy('condition')
            ->get()
            ->keyBy('condition');

        $assetStatus = [
            'available' => $assetStatusCounts->has('available') ? $assetStatusCounts['available']->count : 0,
            'borrowed' => $assetStatusCounts->has('borrowed') ? $assetStatusCounts['borrowed']->count : 0,
            'maintenance' => $assetStatusCounts->has('maintenance') ? $assetStatusCounts['maintenance']->count : 0,
            'damaged' => $assetStatusCounts->has('damaged') ? $assetStatusCounts['damaged']->count : 0,
        ];

        return view('admin.dashboard', compact(
            'totalUsers',
            'totalAssets',
            'pendingUsersCount',
            'totalBorrowings',
            'recentUsers',
            'userGrowthLabels',
            'userGrowthData',
            'assetDistributionLabels',
            'assetDistributionTotalData',
            'assetDistributionAvailableData',
            'borrowTrendLabels',
            'borrowedData',
            'returnedData',
            'assetStatus'
        ));
    }

    public function exportExcel()
    {
        $assets = Commodity::all(); // Fetch all assets
        $borrowings = Borrowing::with('commodities')->get(); // Fetch all borrowings with commodities

        // Create a new Excel file
        return \Maatwebsite\Excel\Facades\Excel::download(new \App\Exports\AssetsExport($assets, $borrowings), 'assets_report.xlsx');
    }

    public function exportPDF()
    {
        $assets = Commodity::all(); // Fetch all assets
        $borrowings = Borrowing::with('commodities')->get(); // Fetch all borrowings with commodities

        // Generate PDF
        $pdf = \PDF::loadView('admin.exports.assets_report', compact('assets', 'borrowings'));
        return $pdf->download('assets_report.pdf');
    }
}
