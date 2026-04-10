@extends('layouts.app')

@section('title', 'Riwayat Peminjaman')

@section('content')
<style>
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        color: #2c3e50;
    }

    .profile-photo {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        object-fit: cover;
    }

    .container {
        max-width: 1200px;
        margin: auto;
        padding: 30px;
        animation: fadeIn 1s ease-in-out;
    }

    h1 {
        font-weight: bold;
        color: #34495e;
        text-align: center;
        margin-bottom: 30px;
        animation: slideDown 0.8s ease-in-out;
    }

    .alert {
        padding: 15px 20px;
        background-color: #dff0d8;
        color: #3c763d;
        border-radius: 8px;
        margin-bottom: 20px;
        animation: fadeIn 0.5s ease-in-out;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        background-color: #ffffff;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        animation: slideUp 0.9s ease-in-out;
    }

    thead {
        background: linear-gradient(90deg, #007bff, #0056b3);
        color: #ffffff;
    }

    th, td {
        padding: 14px 18px;
        text-align: center;
        font-size: 14px;
    }

    tbody tr:nth-child(even) {
        background-color: #f2f2f2;
    }

    tbody tr:hover {
        background-color: #ecf0f1;
        transition: background-color 0.3s ease;
    }

    .status {
        font-weight: bold;
        border-radius: 6px;
        padding: 6px 10px;
        display: inline-block;
        color: #fff;
        font-size: 12px;
    }

    .status.pending { background-color: #f39c12; }
    .status.approved { background-color: #3498db; }
    .status.rejected { background-color: #e74c3c; }
    .status.returned { background-color: #2ecc71; }

    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }

    @keyframes slideDown {
        from { opacity: 0; transform: translateY(-20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes slideUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Modal styles */
    .modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.8);
    }

    .modal-content {
        background-color: #fefefe;
        margin: 5% auto;
        padding: 20px;
        border: 1px solid #888;
        width: 80%;
        max-width: 600px;
        border-radius: 8px;
    }

    .close {
        color: #aaa;
        float: right;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
    }

    .close:hover { color: black; }

    .modal img {
        width: 100%;
        height: auto;
        border-radius: 4px;
    }

    /* Footer tabel Pagination*/
    .pagination-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        margin-top: 15px;
        gap: 10px;
    }

    .entries-info {
        font-size: 13px;
        color: #555;
    }

    .pagination {
        list-style: none;
        display: flex;
        gap: 4px;
        padding: 0;
        margin: 0;
    }

    .pagination li { display: inline-block; }

    .pagination a,
    .pagination span {
        padding: 4px 8px;
        border: 1px solid #ddd;
        border-radius: 6px;
        font-size: 12px;
        color: #333;
        text-decoration: none;
        transition: all 0.2s;
    }

    .pagination a:hover {
        background-color: #007bff;
        color: #fff;
        border-color: #007bff;
    }

    .pagination .active span {
        background-color: #007bff;
        color: #fff;
        border-color: #007bff;
    }

    .pagination .disabled span {
        color: #aaa;
        background: #f9f9f9;
        cursor: not-allowed;
    }

    /* Responsive table jadi card */
    @media (max-width: 900px) {
        table, thead, tbody, th, td, tr { display: block; }
        thead tr { display: none; }
        tbody tr {
            margin-bottom: 15px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
            padding: 12px;
        }
        td {
            text-align: left;
            padding: 8px 10px;
            font-size: 13px;
            border: none;
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #f0f0f0;
        }
        td:last-child { border-bottom: none; }
        td::before {
            content: attr(data-label);
            font-weight: 600;
            color: #555;
        }
    }
</style>

<!-- Modal for viewing photos -->
<div id="photoModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <h3>Foto Bukti Pengembalian</h3>
        <div id="photoContainer"></div>
        <p id="noPhotoMsg" style="text-align: center; color: #666; display: none;">Tidak ada foto tersedia</p>
    </div>
</div>

<script>
    function viewPhotos(photoUrls) {
        var container = document.getElementById('photoContainer');
        var msg = document.getElementById('noPhotoMsg');
        container.innerHTML = '';
        if (photoUrls && photoUrls.length > 0) {
            msg.style.display = 'none';
            photoUrls.forEach(function(url) {
                var img = document.createElement('img');
                img.src = url;
                img.style.width = '100%';
                img.style.height = 'auto';
                img.style.borderRadius = '8px';
                img.style.marginBottom = '10px';
                container.appendChild(img);
            });
        } else {
            msg.style.display = 'block';
        }
        document.getElementById('photoModal').style.display = 'block';
    }

    function closeModal() {
        document.getElementById('photoModal').style.display = 'none';
    }

    window.onclick = function(event) {
        var modal = document.getElementById('photoModal');
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    }
</script>

<div class="container">
    <div class="d-flex align-items-center justify-content-between mb-4" style="position: relative;">
        <h1>Riwayat Peminjaman</h1>
        <div class="notification-wrapper" style="position: absolute; top: 0; right: 0; cursor: pointer;">
        </div>
    </div>

    @if (session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    <table class="table table-bordered">
        <thead>
            <tr>
                <th>No</th>
                <th>Foto Profile</th>
                <th>Nama Murid</th>
                <th>Kelas</th>
                <th>Barang & Jumlah</th>
                <th>Tujuan</th>
                <th>Tanggal / Jam</th>
                <th>Status</th>
                <th>Kondisi Pengembalian</th>
                <th>Dikembalikan Oleh</th>
                <th>Photo</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($borrowings as $borrowing)
                <tr>
                    <td data-label="No">{{ $loop->iteration }}</td>
                    <td data-label="Foto Profile">
                        @if($borrowing->student && $borrowing->student->user)
                            <img src="{{ $borrowing->student->user->profile_picture_url }}" alt="Foto Profile" class="profile-photo">
                        @else
                            <img src="{{ asset('ASSETS/default-profile.png') }}" alt="Foto Profile" width="50" height="50" class="rounded-circle">
                        @endif
                    </td>
                    <td data-label="Nama Murid">{{ $borrowing->student->name ?? '-' }}</td>
                    <td data-label="Kelas">{{ $borrowing->student->schoolClass->name ?? '-' }}</td>
                    <td data-label="Barang & Jumlah">
                        <ul style="list-style-type: none; padding: 0;">
                            @foreach($borrowing->commodities as $commodity)
                                <li>{{ $commodity->name }} ({{ $commodity->pivot->quantity }} unit)</li>
                            @endforeach
                        </ul>
                    </td>
                    <td data-label="Tujuan">{{ $borrowing->tujuan ?? '-' }}</td>
                    <td data-label="Tanggal / Jam">{{ $borrowing->borrow_date ? \Carbon\Carbon::parse($borrowing->borrow_date)->format('d M Y') . ($borrowing->return_time ? ' - ' . $borrowing->return_time : '') : '-' }}</td>
                    <td data-label="Status">
                        <span class="status {{ $borrowing->status }}">
                            {{ ucfirst($borrowing->status) }}
                        </span>
                    </td>
                    <td data-label="Kondisi Pengembalian">{{ $borrowing->return_condition ?? '-' }}</td>
                    <td data-label="Dikembalikan Oleh">{{ $borrowing->student->name ?? '-' }}</td>
                    <td data-label="Photo">
                        @if($borrowing->status === 'returned' && $borrowing->return_photo)
                            <button type="button" class="btn btn-info btn-sm" onclick="viewPhotos([{{ json_encode(asset('storage/' . $borrowing->return_photo)) }}])">Lihat</button>
                        @else
                            -
                        @endif
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="11">Belum ada data peminjaman.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<script>
</script>
@endsection
