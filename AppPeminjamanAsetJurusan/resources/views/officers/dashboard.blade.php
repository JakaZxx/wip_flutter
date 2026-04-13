@extends('layouts.app')


@section('title', 'Dashboard Officer')

@push('styles')
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
    :root {
        --primary-color: #2563eb;
        --primary-hover: #1d4ed8;
        --secondary-color: #f3f4f6;
        --text-dark: #1f2937;
        --text-light: #6b7280;
        --card-bg: #ffffff;
        --border-color: #e5e7eb;
        --status-approved: #10b981;
        --status-pending: #f59e0b;
        --status-rejected: #ef4444;
        --status-returned: #3b82f6;
    }

    body {
        font-family: 'Poppins', sans-serif;
        background-color: var(--secondary-color);
        color: var(--text-dark);
    }

    .main-content {
        padding: 2rem;
    }

    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2rem;
    }

    .dashboard-header h1 {
        font-size: 1.8rem;
        font-weight: 600;
        color: var(--text-dark);
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 1.5rem;
        margin-bottom: 2.5rem;
    }

    .stat-card {
        background-color: var(--card-bg);
        padding: 1.5rem;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        display: flex;
        align-items: center;
        gap: 1rem;
        transition: all 0.3s ease;
    }

    .stat-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 16px rgba(0,0,0,0.1);
    }

    .stat-card .icon-wrapper {
        padding: 1rem;
        border-radius: 50%;
        font-size: 1.8rem;
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .stat-card.peminjaman .icon-wrapper { background-color: #3b82f6; }
    .stat-card.aset .icon-wrapper { background-color: #10b981; }
    .stat-card.persetujuan .icon-wrapper { background-color: #f59e0b; }
    .stat-card.pengembalian .icon-wrapper { background-color: #ef4444; }

    .stat-card .stat-info h3 {
        font-size: 2rem;
        font-weight: 700;
        color: var(--text-dark);
        height: 2.4rem;
        line-height: 2.4rem;
        white-space: nowrap;
        overflow: hidden;
    }

    .stat-card .stat-info p {
        font-size: 0.9rem;
        color: var(--text-light);
        margin: 0;
    }

    .dashboard-section {
        background-color: var(--card-bg);
        padding: 1.5rem;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        margin-bottom: 2.5rem;
    }

    .dashboard-section h2 {
        font-size: 1.3rem;
        font-weight: 600;
        margin-bottom: 1.5rem;
    }

    .quick-actions-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 1.5rem;
    }

    .action-card {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 1.5rem 1rem;
        border-radius: 10px;
        border: 1px solid var(--border-color);
        text-align: center;
        color: var(--text-dark);
        text-decoration: none;
        transition: all 0.3s ease;
    }
    .action-card:hover {
        border-color: var(--primary-color);
        background-color: #f9fafb;
        color: var(--primary-color);
    }
    .action-card i {
        font-size: 2.5rem;
        margin-bottom: 1rem;
    }
    .action-card span {
        font-weight: 500;
    }

    .table-container {
        background-color: var(--card-bg);
        padding: 1.5rem;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        overflow-x: auto;
    }

    .table-container h2 {
        font-size: 1.2rem;
        font-weight: 600;
        margin-bottom: 1rem;
    }

    .custom-table {
        width: 100%;
        border-collapse: collapse;
    }

    .custom-table th, .custom-table td {
        padding: 0.8rem 1rem;
        text-align: left;
        border-bottom: 1px solid var(--border-color);
        vertical-align: middle;
    }

    .custom-table th {
        font-weight: 600;
        font-size: 0.85rem;
        color: var(--text-light);
        text-transform: uppercase;
    }

    .status-badge {
        padding: 5px 12px;
        border-radius: 15px;
        font-size: 0.8rem;
        font-weight: 600;
        color: #fff;
        text-align: center;
        display: inline-block;
    }
    .status-approved { background-color: var(--status-approved); }
    .status-pending { background-color: var(--status-pending); }
    .status-rejected { background-color: var(--status-rejected); }
    .status-returned { background-color: var(--status-returned); }

    .dashboard-grid-col-2 {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 1.5rem;
        margin-top: 2rem;
    }
    
    @media (max-width: 992px) {
        .dashboard-grid-col-2 {
            grid-template-columns: 1fr;
        }
    }

    .requests-list ul, .reminders-list ul {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .requests-list li, .reminders-list li {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 1rem 0;
        border-bottom: 1px solid var(--border-color);
    }
    .requests-list li:last-child, .reminders-list li:last-child {
        border-bottom: none;
    }

    .reminders-list .reminder-card {
        background-color: #fffbe6;
        border: 1px solid #fef08a;
        border-radius: 8px;
        padding: 1rem;
        height: 100%;
    }
    .reminders-list .reminder-card h2 {
        color: #a16207;
    }
    .reminders-list .reminder-card .text-bold {
        font-weight: 600;
    }
    .reminders-list .reminder-card .text-danger {
        color: #dc2626;
        font-weight: 600;
    }

    .footer {
        text-align: center;
        padding: 1.5rem;
        margin-top: 2rem;
        color: var(--text-light);
        font-size: 0.9rem;
    }

    /* 🔥 Animasi Slide Up */
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(40px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    .chart-container {
        height: 200px;
        width: 100%;
        position: relative;
    }
    .chart-container canvas {
        height: 100% !important;
        width: 100% !important;
    }
    .chart-card {
        min-height: 280px;
    }

    .slide-up {
        opacity: 0;
        animation: slideUp 0.8s ease-out forwards;
    }

    @media (max-width: 768px) {
        .main-content {
            padding: 0.25rem;
        }

        .dashboard-header {
            margin-bottom: 0.75rem;
        }

        .dashboard-header h1 {
            font-size: 1.1rem;
        }

        .stats-grid, .charts-grid {
            grid-template-columns: 1fr;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }

        .stat-card {
            padding: 0.5rem;
            gap: 0.5rem;
            min-height: auto;
            max-width: 100%;
            box-sizing: border-box;
        }

        .stat-card .icon-wrapper {
            padding: 0.5rem;
            font-size: 1.2rem;
        }

        .stat-card .stat-info h3 {
            font-size: 1.2rem;
        }

        .stat-card .stat-info p {
            font-size: 0.7rem;
        }

        .dashboard-section {
            padding: 0.5rem;
            margin-bottom: 1rem;
        }

        .dashboard-section h2 {
            font-size: 0.9rem;
            margin-bottom: 0.75rem;
        }

        .quick-actions-grid {
            grid-template-columns: repeat(2, 1fr);
            gap: 0.5rem;
        }

        .action-card {
            padding: 0.5rem 0.25rem;
        }

        .action-card i {
            font-size: 1.5rem;
            margin-bottom: 0.25rem;
        }

        .action-card span {
            font-size: 0.7rem;
        }

        .data-management-grid {
            grid-template-columns: 1fr;
            gap: 0.5rem;
        }

        .custom-table {
            font-size: 0.7rem;
            width: 100%;
            table-layout: fixed;
        }

        .custom-table th, .custom-table td {
            padding: 0.3rem 0.25rem;
            word-wrap: break-word;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .custom-table th:nth-child(1), .custom-table td:nth-child(1) { width: 25%; }
        .custom-table th:nth-child(2), .custom-table td:nth-child(2) { width: 30%; }
        .custom-table th:nth-child(3), .custom-table td:nth-child(3) { width: 15%; }
        .custom-table th:nth-child(4), .custom-table td:nth-child(4) { width: 20%; }
        .custom-table th:nth-child(5), .custom-table td:nth-child(5) { width: 10%; }

        .custom-table .role-badge {
            padding: 1px 4px;
            font-size: 0.6rem;
        }

        .btn-approve {
            padding: 2px 4px;
            font-size: 0.6rem;
        }

        .chart-container {
            height: 100px;
        }

        .chart-card {
            min-height: 160px;
            padding: 0.75rem !important;
        }

        .chart-card h3 {
            font-size: 0.9rem;
            margin-bottom: 0.25rem;
        }

        .chart-card p {
            font-size: 0.7rem;
            margin-bottom: 0.5rem;
        }
    }

    @media (max-width: 480px) {
        .main-content {
            padding: 0.5rem;
        }

        .dashboard-header h1 {
            font-size: 1.3rem;
        }

        .stat-card {
            flex-direction: column;
            text-align: center;
            gap: 0.5rem;
        }

        .quick-actions-grid {
            grid-template-columns: 1fr;
        }

        .action-card {
            flex-direction: row;
            justify-content: flex-start;
            text-align: left;
            padding: 0.8rem;
        }

        .action-card i {
            font-size: 1.5rem;
            margin-bottom: 0;
            margin-right: 0.5rem;
        }

        .action-card span {
            font-size: 0.9rem;
        }
    }
</style>
@endpush

@section('content')
<div class="main-content">
    <header class="dashboard-header slide-up">
        <h1>Halo Officer, Selamat Datang!</h1>
    </header>

    {{-- Statistik Cards --}}
    <div class="stats-grid slide-up">
        <div class="stat-card peminjaman">
            <div class="icon-wrapper"><i class="fas fa-book-open"></i></div>
            <div class="stat-info">
                <h3 data-target="{{ $activeBorrowingsCount }}">0</h3>
                <p>Peminjaman Aktif</p>
            </div>
        </div>
        <div class="stat-card aset">
            <div class="icon-wrapper"><i class="fas fa-box"></i></div>
            <div class="stat-info">
                <h3 data-target="{{ $totalAssetsCount }}">0</h3>
                <p>Total Aset Jurusan</p>
            </div>
        </div>
        <div class="stat-card persetujuan">
            <div class="icon-wrapper"><i class="fas fa-clock"></i></div>
            <div class="stat-info">
                <h3 data-target="{{ $pendingRequestsCount }}">0</h3>
                <p>Menunggu Persetujuan</p>
            </div>
        </div>
        <div class="stat-card pengembalian">
            <div class="icon-wrapper"><i class="fas fa-undo-alt"></i></div>
            <div class="stat-info">
                <h3 data-target="{{ $overdueBorrowingsCount }}">0</h3>
                <p>Jatuh Tempo</p>
            </div>
        </div>
    </div>

    {{-- Quick Actions --}}
    <div class="dashboard-section slide-up">
        <h2>Aksi Cepat</h2>
        <div class="quick-actions-grid">
            <a href="{{ route('officers.assets.index') }}" class="action-card">
                <i class="fas fa-boxes-stacked"></i>
                <span>Kelola Aset</span>
            </a>
            <a href="{{ route('officers.borrowings.index') }}" class="action-card">
                <i class="fas fa-tasks"></i>
                <span>Proses Peminjaman</span>
            </a>
            <a href="{{ route('borrowing.request.create.officers') }}" class="action-card">
                <i class="fas fa-plus-circle"></i>
                <span>Buat Peminjaman</span>
            </a>
            <a href="{{ route('officers.classes.index') }}" class="action-card">
                <i class="fas fa-school"></i>
                <span>Kelola Kelas</span>
            </a>
        </div>
    </div>

    {{-- Statistics Charts --}}
    <div class="stats-grid slide-up" style="margin-bottom: 2.5rem;">
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column;">
            <h3>Pertumbuhan Pengguna</h3>
            <p>Total pengguna dalam 6 bulan terakhir</p>
            <div class="chart-container">
                <canvas id="userGrowthChart"></canvas>
            </div>
        </div>
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column;">
            <h3>Distribusi Aset</h3>
            <p>Perbandingan total vs tersedia</p>
            <div class="chart-container">
                <canvas id="assetDistributionChart"></canvas>
            </div>
        </div>
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column;">
            <h3>Tren Peminjaman</h3>
            <p>6 minggu terakhir</p>
            <div class="chart-container">
                <canvas id="borrowingTrendChart"></canvas>
            </div>
        </div>
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column;">
            <h3>Status Aset</h3>
            <p>Ringkasan kondisi seluruh aset</p>
            <div class="chart-container">
                <canvas id="assetStatusChart"></canvas>
            </div>
        </div>
    </div>

    <div class="dashboard-grid-col-2 slide-up">
        {{-- Permintaan Baru --}}
        <div class="table-container requests-list">
            <h2>Permintaan Peminjaman Baru @if($pendingRequestsCount > 0)<span class="status-badge status-pending">{{ $pendingRequestsCount }}</span>@endif</h2>
            <ul>
                @forelse($newRequests as $request)
                <li>
                    <div>
                        <strong>{{ $request->student->user->name }}</strong> ({{ $request->student->schoolClass->class_name ?? 'N/A' }}) <br>
                        <small>Meminjam {{ $request->items->map(fn($item) => $item->quantity . 'x ' . $item->commodity->item_name)->implode(', ') }}</small>
                    </div>
                    <a href="{{ route('officers.borrowings.index') }}" class="btn btn-primary btn-sm">Lihat</a>
                </li>
                @empty
                <li>Tidak ada permintaan baru.</li>
                @endforelse
            </ul>
        </div>

        {{-- Reminder Section --}}
        <div class="reminders-list">
            <div class="reminder-card">
                <h2><i class="fas fa-bell"></i> Pengingat Jatuh Tempo</h2>
                <ul>
                    @forelse($dueSoonBorrowings as $borrowing)
                    <li>
                        <div>
                            <span class="text-bold">{{ $borrowing->student->user->name }}</span> ({{ $borrowing->student->schoolClass->class_name ?? 'N/A' }})<br>
                            <small>Jatuh tempo <span class="text-danger">{{ $borrowing->return_date ? \Carbon\Carbon::parse($borrowing->return_date)->diffForHumans() : '-' }}</span></small>
                        </div>
                    </li>
                    @empty
                    <li>Tidak ada peminjaman yang akan jatuh tempo.</li>
                    @endforelse
                </ul>
            </div>
        </div>
    </div>

    {{-- Tabel Peminjaman Aktif --}}
    <div class="table-container slide-up" style="margin-top: 2rem;">
        <h2>Aktivitas Peminjaman Terbaru</h2>
        <table class="custom-table">
            <thead>
                <tr>
                    <th>Peminjam</th>
                    <th>Barang & Jumlah</th>
                    <th>Tgl Pinjam</th>
                    <th>Tgl Kembali</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse($recentActivities as $activity)
                <tr>
                    <td>{{ $activity->student->user->name ?? 'N/A' }}</td>
                    <td>{{ $activity->items->map(fn($item) => $item->commodity->item_name . ' (' . $item->quantity . ')')->implode(', ') }}</td>
                    <td>{{ $activity->borrow_date ? \Carbon\Carbon::parse($activity->borrow_date)->format('d-m-Y') : '-' }}</td>
                    <td>{{ $activity->return_date ? \Carbon\Carbon::parse($activity->return_date)->format('d-m-Y') : '-' }}</td>
                    <td>
                        @php
                            $statusClass = 'status-' . strtolower($activity->status);
                        @endphp
                        <span class="status-badge {{ $statusClass }}">{{ ucfirst($activity->status) }}</span>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" style="text-align: center;">Tidak ada aktivitas peminjaman.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <footer class="footer slide-up">
        © 2025 4LLAset. All rights reserved.
    </footer>
</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    // Efek Count Up untuk Statistik
    const counters = document.querySelectorAll('.stat-info h3');
    const countUp = (counter) => {
        const target = +counter.getAttribute('data-target');
        const duration = 1500;
        let startTimestamp = null;

        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            const currentValue = Math.floor(progress * target);
            counter.innerText = currentValue;

            if (progress < 1) {
                window.requestAnimationFrame(step);
            } else {
                counter.innerText = target;
            }
        };
        window.requestAnimationFrame(step);
    };

    const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                countUp(entry.target);
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    counters.forEach(counter => {
        observer.observe(counter);
    });

    // User Growth Chart
    const userGrowthCtx = document.getElementById('userGrowthChart').getContext('2d');
    new Chart(userGrowthCtx, {
        type: 'line',
        data: {
            labels: @json($userGrowthLabels),
            datasets: [{
                label: 'Pengguna Baru',
                data: @json($userGrowthData),
                borderColor: '#3b82f6',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: { beginAtZero: true }
            }
        }
    });

    // Asset Distribution Chart
    const assetDistributionCtx = document.getElementById('assetDistributionChart').getContext('2d');
    new Chart(assetDistributionCtx, {
        type: 'bar',
        data: {
            labels: @json($assetDistributionLabels),
            datasets: [{
                label: 'Total',
                data: @json($assetDistributionTotalData),
                backgroundColor: '#10b981'
            }, {
                label: 'Tersedia',
                data: @json($assetDistributionAvailableData),
                backgroundColor: '#6b7280'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'top' }
            },
            scales: {
                y: { beginAtZero: true }
            }
        }
    });

    // Borrowing Trend Chart
    const borrowingTrendCtx = document.getElementById('borrowingTrendChart').getContext('2d');
    new Chart(borrowingTrendCtx, {
        type: 'line',
        data: {
            labels: @json($borrowTrendLabels),
            datasets: [{
                label: 'Dipinjam',
                data: @json($borrowedData),
                borderColor: '#8b5cf6',
                backgroundColor: 'rgba(139, 92, 246, 0.1)',
                tension: 0.4
            }, {
                label: 'Dikembalikan',
                data: @json($returnedData),
                borderColor: '#f59e0b',
                backgroundColor: 'rgba(245, 158, 11, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'top' }
            },
            scales: {
                y: { beginAtZero: true }
            }
        }
    });

    // Asset Status Chart
    const assetStatusCtx = document.getElementById('assetStatusChart').getContext('2d');
    new Chart(assetStatusCtx, {
        type: 'doughnut',
        data: {
            labels: ['Tersedia', 'Dipinjam', 'Maintenance', 'Rusak'],
            datasets: [{
                data: [@json($assetStatus['available']), @json($assetStatus['borrowed']), @json($assetStatus['maintenance']), @json($assetStatus['damaged'])],
                backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#ef4444']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });
});
</script>
@endpush
