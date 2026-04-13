@extends('layouts.app')

@section('title', 'Dashboard Admin')

@push('styles')
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
<link rel="stylesheet" href="{{ asset('css/admin-dashboard.css') }}">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
@endpush

@section('content')
<div class="main-content">
    <div class="dashboard-header slide-up" style="animation-delay:0.1s;">
        <h1>Dashboard Admin</h1>
    </div>

    {{-- Statistik Cards --}}
    <div class="stats-grid">
        <div class="stat-card users" style="animation-delay:0.2s;">
            <div class="icon-wrapper"><i class="fas fa-users"></i></div>
            <div class="stat-info">
                <h3>{{ $totalUsers }}</h3>
                <p>Total Pengguna</p>
            </div>
        </div>
        <div class="stat-card assets" style="animation-delay:0.3s;">
            <div class="icon-wrapper"><i class="fas fa-box-archive"></i></div>
            <div class="stat-info">
                <h3>{{ $totalAssets }}</h3>
                <p>Total Aset</p>
            </div>
        </div>
        <div class="stat-card pending" style="animation-delay:0.4s;">
            <div class="icon-wrapper"><i class="fas fa-user-clock"></i></div>
            <div class="stat-info">
                <h3>{{ $pendingUsersCount }}</h3>
                <p>Persetujuan Tertunda</p>
            </div>
        </div>
        <div class="stat-card borrowings" style="animation-delay:0.5s;">
            <div class="icon-wrapper"><i class="fas fa-retweet"></i></div>
            <div class="stat-info">
                <h3>{{ $totalBorrowings }}</h3>
                <p>Total Peminjaman</p>
            </div>
        </div>
    </div>

    {{-- New Statistics Charts --}}
    <div class="charts-grid" style="margin-bottom: 2.5rem;">
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column; animation-delay:0.6s;">
            <h3>Pertumbuhan Pengguna</h3>
            <p>Total pengguna dalam 6 bulan terakhir</p>
            <div class="chart-container">
                <canvas id="userGrowthChart"></canvas>
            </div>
        </div>
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column; animation-delay:0.7s;">
            <h3>Distribusi Aset</h3>
            <p>Perbandingan total vs tersedia</p>
            <div class="chart-container">
                <canvas id="assetDistributionChart"></canvas>
            </div>
        </div>
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column; animation-delay:0.8s;">
            <h3>Tren Peminjaman</h3>
            <p>6 minggu terakhir</p>
            <div class="chart-container">
                <canvas id="borrowingTrendChart"></canvas>
            </div>
        </div>
        <div class="stat-card chart-card" style="padding: 1rem; flex-direction: column; animation-delay:0.9s;">
            <h3>Status Aset</h3>
            <p>Ringkasan kondisi seluruh aset</p>
            <div class="chart-container">
                <canvas id="assetStatusChart"></canvas>
            </div>
        </div>
    </div>

    {{-- Quick Actions --}}
    <div class="dashboard-section" style="animation-delay:0.6s;">
        <h2>Aksi Cepat</h2>
        <div class="quick-actions-grid">
            <a href="{{ route('users.index') }}" class="action-card" style="animation-delay:0.7s;">
                <i class="fas fa-users-cog"></i>
                <span>Kelola Pengguna</span>
            </a>
            <a href="{{ route('admin.assets.index') }}" class="action-card" style="animation-delay:0.8s;">
                <i class="fas fa-boxes-stacked"></i>
                <span>Kelola Aset</span>
            </a>
            <a href="{{ route('admin.classes.index') }}" class="action-card" style="animation-delay:0.9s;">
                <i class="fas fa-school"></i>
                <span>Kelola Kelas</span>
            </a>
            <a href="{{ route('admin.borrowings.index') }}" class="action-card" style="animation-delay:1s;">
                <i class="fas fa-history"></i>
                <span>Riwayat Pinjam</span>
            </a>
        </div>
    </div>

    {{-- Recent Activity --}}
    <div class="dashboard-section" style="animation-delay:1.1s;">
        <h2>Persetujuan Pengguna Baru</h2>
        <div class="table-responsive" style="overflow-x: auto; -webkit-overflow-scrolling: touch;">
            <table class="custom-table">
                <thead>
                    <tr>
                        <th>Nama</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Tanggal Daftar</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($recentUsers as $user)
                        <tr>
                            <td>{{ $user->name }}</td>
                            <td>{{ $user->email }}</td>
                            <td><span class="role-badge">{{ ucfirst($user->role) }}</span></td>
                            <td>{{ $user->created_at ? $user->created_at->format('d M Y') : '-' }}</td>
                            <td>
                                <a href="{{ route('users.index') }}" class="btn-approve">Lihat</a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 1rem;">Tidak ada pengguna baru yang menunggu persetujuan.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- Data Management --}}
    <div class="dashboard-section" style="animation-delay:1.3s;">
        <h2>Manajemen Data</h2>
        <div class="data-management-grid">
            <a href="{{ route('users.index') }}?action=import" class="action-card" style="animation-delay:1.4s;">
                <i class="fas fa-file-import"></i>
                <span>Import Data</span>
            </a>
            <a href="{{ route('admin.export.excel') }}" class="action-card" style="animation-delay:1.5s;">
                <i class="fas fa-file-excel"></i>
                <span>Export Laporan</span>
            </a>
        </div>
    </div>

</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
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
