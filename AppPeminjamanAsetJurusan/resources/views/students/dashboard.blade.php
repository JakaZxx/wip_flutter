@extends('layouts.app')

@section('content')
<style>
    /* Poppins Font */
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');

    body {
        font-family: 'Poppins', sans-serif;
        background-color: #f4f7fc;
        color: #495057;
    }

    .student-dashboard .card {
        border: none;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        margin-bottom: 2rem;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .student-dashboard .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
    }

    .student-dashboard .card-header {
        background-color: #fff;
        border-bottom: 1px solid #e3e6f0;
        font-weight: 600;
        font-size: 1.1rem;
        padding: 1rem 1.5rem;
        border-top-left-radius: 12px;
        border-top-right-radius: 12px;
    }

    /* 1. Quick Overview Stats Cards */
    .stat-card {
        background: #fff;
        padding: 1.5rem;
        text-align: left;
        border-radius: 12px;
        display: flex;
        align-items: center;
        gap: 1rem;
    }

    .stat-icon {
        font-size: 2rem;
        width: 60px;
        height: 60px;
        display: grid;
        place-items: center;
        border-radius: 50%;
        color: #fff;
    }

    .stat-card:nth-child(1) .stat-icon { background: linear-gradient(135deg, #007bff, #0056b3); }
    .stat-card:nth-child(2) .stat-icon { background: linear-gradient(135deg, #28a745, #218838); }
    .stat-card:nth-child(3) .stat-icon { background: linear-gradient(135deg, #ffc107, #e0a800); }
    .stat-card:nth-child(4) .stat-icon { background: linear-gradient(135deg, #dc3545, #c82333); }

    .stat-info .title {
        font-size: 0.9rem;
        font-weight: 500;
        color: #6c757d;
        margin-bottom: 0.25rem;
    }

    .stat-info .value {
        font-size: 1.75rem;
        font-weight: 700;
        color: #343a40;
    }

    /* 2. Quick Actions */
    .quick-actions .btn {
        width: 100%;
        padding: 0.75rem;
        font-size: 1rem;
        font-weight: 600;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
        transition: all 0.2s ease;
    }
    .quick-actions .btn i {
        margin-right: 8px;
    }

    /* 4. Recent Borrowings Table */
    .table {
        border-collapse: separate;
        border-spacing: 0 8px;
    }
    .table th {
        font-weight: 600;
        color: #007bff;
        border: none;
    }
    .table td {
        background: #fff;
        vertical-align: middle;
        border: none;
    }
    .table tr:hover td {
        background: #f8f9fa;
    }
    .table td:first-child { border-top-left-radius: 8px; border-bottom-left-radius: 8px; }
    .table td:last-child { border-top-right-radius: 8px; border-bottom-right-radius: 8px; }

    .badge-status {
        padding: 0.5em 0.9em;
        border-radius: 30px;
        font-size: 0.8rem;
        font-weight: 600;
        text-transform: capitalize;
    }
    .badge-status.pending { background-color: #fff3cd; color: #856404; }
    .badge-status.approved { background-color: #d4edda; color: #155724; }
    .badge-status.returned { background-color: #d1ecf1; color: #0c5460; }
    .badge-status.overdue { background-color: #f8d7da; color: #721c24; }

    /* 5. Reminders & Notifications */
    .alert-reminder {
        display: flex;
        align-items: center;
        gap: 1rem;
        background-color: #fff3cd;
        border-left: 5px solid #ffc107;
        padding: 1rem;
        border-radius: 8px;
    }
    .alert-reminder .icon { font-size: 1.5rem; color: #ffc107; }

    /* 6. Tips Section */
    .tips-card {
        background: linear-gradient(135deg, #e0f7fa, #b2ebf2);
        border-left: 5px solid #00bcd4;
    }
    .tips-card .card-body {
        font-size: 0.9rem;
    }

</style>

<div class="container-fluid student-dashboard py-4">

    <!-- Page Heading -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Halo, {{ Auth::user()->name }}!</h1>
    </div>

    <!-- 1. Quick Overview -->
    <div class="row">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-box-open"></i></div>
                <div class="stat-info">
                    <div class="title">Aset Tersedia</div>
                    <div class="value">{{ $totalAvailableAssets ?? 0 }}</div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-shopping-basket"></i></div>
                <div class="stat-info">
                    <div class="title">Sedang Dipinjam</div>
                    <div class="value">{{ $myActiveBorrowingsCount ?? 0 }}</div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-hourglass-half"></i></div>
                <div class="stat-info">
                    <div class="title">Pending</div>
                    <div class="value">{{ $pendingBorrowingsCount ?? 0 }}</div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-exclamation-triangle"></i></div>
                <div class="stat-info">
                    <div class="title">Approved/Jatuh Tempo</div>
                    <div class="value">{{ $approvedOrOverdueBorrowingsCount ?? 0 }}</div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- Left Column: Actions, Charts, Reminders -->
        <div class="col-lg-8">
            <!-- 2. Quick Actions -->
            <div class="card">
                <div class="card-header">Aksi Cepat</div>
                <div class="card-body quick-actions">
                    <div class="row">
                        <div class="col-md-4 mb-2">
                            <a href="{{ route('borrowing.request.create.student') }}" class="btn btn-primary"><i class="fas fa-plus-circle"></i>Pinjam Aset</a>
                        </div>
                        <div class="col-md-4 mb-2">
                            <a href="{{ route('students.borrowings.index') }}" class="btn btn-info text-white"><i class="fas fa-history"></i>Riwayat</a>
                        </div>
                        <div class="col-md-4 mb-2">
                            <a href="{{ route('students.borrowings.index') }}" class="btn btn-success"><i class="fas fa-undo-alt"></i>Kembalikan Aset</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 3. Charts -->
            <div class="row">
                <div class="col-md-7">
                    <div class="card">
                        <div class="card-header">Tren Peminjaman (6 Bulan Terakhir)</div>
                        <div class="card-body">
                            <canvas id="borrowingTrendChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-5">
                    <div class="card">
                        <div class="card-header">Status Peminjaman</div>
                        <div class="card-body">
                            <canvas id="borrowingStatusChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 5. Reminders -->
            @if($upcomingDueBorrowings->count() > 0)
                @php $firstDue = $upcomingDueBorrowings->first(); @endphp
                <div class="alert-reminder mt-2">
                    <div class="icon"><i class="fas fa-bell"></i></div>
                    <div>
                        <strong>Pengingat:</strong> Peminjaman "
                        @foreach($firstDue->commodities as $commodity)
                            {{ $commodity->name }} ({{ $commodity->pivot->quantity }})
                        @endforeach
                        " akan jatuh tempo pada <strong>{{ \Carbon\Carbon::parse($firstDue->return_date)->translatedFormat('d M Y') }}</strong>.
                    </div>
                </div>
            @endif
        </div>

        <!-- Right Column: Recent Borrowings & Tips -->
        <div class="col-lg-4">
            <!-- 4. Recent Borrowings -->
            <div class="card">
                <div class="card-header">Peminjaman Terbaru</div>
                <div class="card-body">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Aset</th>
                                <th>Status</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($recentRequests as $borrowing)
                            <tr>
                                <td>
                                    <ul style="list-style-type: none; padding: 0; margin: 0;">
                                        @foreach($borrowing->commodities as $commodity)
                                            <li>{{ $commodity->name }} ({{ $commodity->pivot->quantity }})</li>
                                        @endforeach
                                    </ul>
                                </td>
                                <td>
                                    @php
                                        $statusClass = '';
                                        switch ($borrowing->status) {
                                            case 'approved': $statusClass = 'approved'; break;
                                            case 'pending': $statusClass = 'pending'; break;
                                            case 'returned': $statusClass = 'returned'; break;
                                            case 'overdue': $statusClass = 'overdue'; break;
                                            default: $statusClass = 'pending'; break;
                                        }
                                    @endphp
                                    <span class="badge-status {{ $statusClass }}">{{ ucfirst($borrowing->status) }}</span>
                                </td>
                                <td>
                                    @if($borrowing->status == 'pending')
                                        <a href="#" class="btn btn-sm btn-outline-danger">Batal</a>
                                    @else
                                        <a href="{{ route('students.borrowings.show', $borrowing->id) }}" class="btn btn-sm btn-outline-primary">Detail</a>
                                    @endif
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="3" class="text-center text-muted">Tidak ada peminjaman terbaru.</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 6. Tips -->
            <div class="card tips-card">
                <div class="card-body">
                    <h5 class="font-weight-bold"><i class="fas fa-lightbulb mr-2"></i>Tips Merawat Aset</h5>
                    <p>Selalu periksa kelengkapan aset sebelum dan sesudah meminjam. Laporkan jika ada kerusakan agar tidak menjadi tanggung jawabmu.</p>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    // 3. Charts/Statistics
    // a. Borrowing Trend (Line Chart)
    var ctxLine = document.getElementById('borrowingTrendChart').getContext('2d');
    new Chart(ctxLine, {
        type: 'line',
        data: {
            labels: @json($months), // Dynamic months
            datasets: [{
                label: 'Jumlah Peminjaman',
                data: @json($borrowingTrend), // Dynamic borrowing trend data
                borderColor: '#007bff',
                backgroundColor: 'rgba(0, 123, 255, 0.1)',
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1
                    }
                }
            }
        }
    });

    // b. Borrowing Status (Pie Chart)
    var ctxPie = document.getElementById('borrowingStatusChart').getContext('2d');
    new Chart(ctxPie, {
        type: 'doughnut',
        data: {
            labels: @json($chartStatusLabels), // Dynamic status labels
            datasets: [{
                data: @json($chartStatusData), // Dynamic status data
                backgroundColor: ['#28a745', '#ffc107', '#17a2b8', '#dc3545', '#6c757d'], // Colors for approved, pending, returned, overdue, rejected
                borderColor: '#fff',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                }
            }
        }
    });
});
</script>
@endpush