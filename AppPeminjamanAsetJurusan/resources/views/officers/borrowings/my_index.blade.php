@extends('layouts.app')

@section('title', 'Status Peminjaman Saya')

@section('content')
<style>
    /* Poppins Font - Consistent with Dashboard */
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');

    body {
        font-family: 'Poppins', sans-serif;
        background-color: #f4f7fc; /* Consistent background */
        color: #495057;
    }

    .page-container {
        width: 100%;
        padding: 20px 30px;
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    .page-title {
        font-size: 2rem; /* Slightly larger for main title */
        font-weight: 700;
        color: #2c3e50;
        text-align: center;
        margin-bottom: 30px; /* More space */
        animation: fadeDown 0.8s ease forwards;
    }

    .cards-container {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: 25px; /* Increased gap for better spacing */
        padding: 0 20px;
        box-sizing: border-box;
    }

    .card {
        background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        border-radius: 16px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.1), 0 2px 8px rgba(0,0,0,0.05);
        padding: 24px;
        width: 340px; /* Slightly wider cards */
        opacity: 0;
        transform: translateY(30px);
        animation: fadeUp 0.8s ease forwards;
        display: flex;
        flex-direction: column;
        gap: 16px;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        border: 1px solid rgba(255,255,255,0.2);
    }

    .card:hover {
        transform: translateY(-8px); /* More pronounced hover effect */
        box-shadow: 0 12px 40px rgba(0,0,0,0.15), 0 4px 12px rgba(0,0,0,0.1);
    }

    .card img, .card .no-image {
        width: 100%;
        height: 180px; /* Taller images */
        object-fit: cover;
        border-radius: 10px; /* Slightly more rounded corners */
        background-color: #eaeaea;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 3.5rem; /* Larger icon */
        color: #ccc;
    }

    .slider {
        position: relative;
        width: 100%;
        height: 180px; /* Taller slider */
        overflow: hidden;
        border-radius: 10px;
    }

    .slider-images {
        display: flex;
        width: 100%;
        height: 100%;
        transition: transform 0.5s ease;
    }

    .slider img, .slider .no-image {
        min-width: 100%;
        height: 100%;
        object-fit: cover;
        flex-shrink: 0;
    }

    .slider-btn {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        background: rgba(0, 123, 255, 0.7); /* Semi-transparent blue */
        color: white;
        border: none;
        padding: 8px 10px; /* Larger buttons */
        border-radius: 50%;
        cursor: pointer;
        font-size: 1rem; /* Larger icon */
        transition: background 0.3s ease, transform 0.2s ease, opacity 0.3s ease;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        pointer-events: all;
        z-index: 10;
        opacity: 0.9;
    }

    .slider-btn:hover {
        background: #0056b3; /* Solid blue on hover */
        transform: translateY(-50%) scale(1.1);
        opacity: 1;
    }

    .slider-btn.prev {
        left: 15px; /* More padding */
    }

    .slider-btn.next {
        right: 15px; /* More padding */
    }

    .dots {
        display: flex;
        gap: 10px; /* Increased gap */
        justify-content: center;
        margin-top: 15px; /* More margin */
    }

    .dot {
        width: 14px; /* Larger dots */
        height: 14px;
        background-color: #bbb;
        border-radius: 50%;
        display: inline-block;
        cursor: pointer;
        transition: background-color 0.3s ease;
        box-shadow: 0 0 3px rgba(0,0,0,0.1);
    }

    .dot.active {
        background-color: #007bff;
        box-shadow: 0 0 8px #007bff;
    }

    .current-commodity {
        font-weight: 700;
        font-size: 1.2rem; /* Larger font */
        color: #333;
        margin-top: 10px;
        text-align: center;
    }

    .info-text {
        font-size: 0.95rem; /* Slightly larger font */
        margin-bottom: 6px; /* More spacing */
        display: flex;
        align-items: center;
        gap: 10px; /* Increased gap */
    }

    .info-text b {
        font-weight: 700;
        color: #2c3e50; /* Darker bold text */
    }

    /* Consistent status badges with dashboard */
    .badge {
        display: inline-block;
        padding: 6px 10px;
        border-radius: 6px;
        font-weight: 600;
        font-size: 0.85rem;
    }
    .badge.bg-success { background: linear-gradient(90deg,#28a745,#218838); color: #fff; }
    .badge.bg-warning { background: linear-gradient(90deg,#f39c12,#d68910); color: #fff; }
    .badge.bg-danger  { background: linear-gradient(90deg,#dc3545,#c82333); color: #fff; }
    .badge.bg-info    { background: linear-gradient(90deg,#17a2b8,#117a8b); color: #fff; }

    .status-ongoing, .status-returned, .btn-primary {
        border-radius: 12px;
        padding: 10px 20px; /* Larger padding */
        font-weight: 700;
        font-size: 1rem; /* Larger font */
        text-align: center;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        transition: background-color 0.3s ease, box-shadow 0.3s ease;
        cursor: default;
        user-select: none;
        max-width: fit-content;
        margin-top: 15px; /* More margin */
        display: flex;
        align-items: center;
        gap: 10px; /* Increased gap */
    }

    .status-ongoing {
        background: linear-gradient(90deg, #ffc107, #e0a800); /* Gradient for consistency */
        color: #000;
    }

    .status-ongoing:hover {
        background: linear-gradient(90deg, #e0a800, #cc9500);
        box-shadow: 0 6px 16px rgba(255,193,7,0.4);
    }

    .status-returned {
        background: linear-gradient(90deg, #28a745, #218838); /* Gradient for consistency */
        color: white;
    }

    .status-returned:hover {
        background: linear-gradient(90deg, #218838, #1a732e);
        box-shadow: 0 6px 16px rgba(40,167,69,0.4);
    }

    .btn-primary {
        background: linear-gradient(90deg, #007bff, #0056b3); /* Gradient for consistency */
        color: white;
        border: none;
        cursor: pointer;
        user-select: auto;
        max-width: fit-content;
        margin-top: 15px;
        align-self: flex-start;
        box-shadow: 0 6px 16px rgba(0,123,255,0.4);
        transition: background-color 0.3s ease, box-shadow 0.3s ease;
    }

    .btn-primary:hover {
        background: linear-gradient(90deg, #0056b3, #004085);
        box-shadow: 0 8px 20px rgba(0,86,179,0.6);
    }

    .text-muted {
        font-size: 0.9rem;
        color: #777;
    }

    .status-rejected {
        font-size: 0.95rem; /* Slightly larger */
        color: #dc3545;
        font-weight: 700;
    }

    .item-statuses {
        margin-top: 15px; /* More margin */
        padding: 12px; /* More padding */
        background: #f0f4f8; /* Lighter background */
        border-radius: 10px; /* More rounded corners */
        font-size: 0.9rem;
    }

    .item-statuses div {
        margin-bottom: 6px; /* More spacing */
    }

    .item-statuses div:last-child {
        margin-bottom: 0;
    }

    /* Pagination styles (from admin/users/index.blade.php) */
    .pagination-container {
        display: flex;
        justify-content: space-between; /* Align items to start and end */
        align-items: center;
        margin-top: 30px;
        padding: 15px 20px; /* Add padding */
        background-color: #fff; /* White background */
        border-radius: 12px; /* Rounded corners */
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); /* Subtle shadow */
    }

    .entries-info {
        font-size: 0.9rem;
        color: #6c757d;
    }

    .pagination {
        display: flex;
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .pagination li {
        margin: 0 2px; /* Small margin between items */
    }

    .pagination li a, .pagination li span {
        display: block;
        padding: 8px 12px; /* Adjust padding */
        text-decoration: none;
        color: #007bff;
        background-color: #fff;
        border: 1px solid #dee2e6;
        border-radius: 6px; /* Rounded buttons */
        transition: all 0.3s ease;
        font-size: 0.9rem;
        min-width: 35px; /* Ensure consistent width */
        text-align: center;
    }

    .pagination li a:hover {
        background-color: #e9ecef;
        color: #0056b3;
        border-color: #0056b3;
    }

    .pagination li.active span {
        background-color: #007bff;
        color: #fff;
        border-color: #007bff;
        z-index: 1;
    }

    .pagination li.disabled span {
        color: #6c757d;
        background-color: #fff;
        cursor: not-allowed;
        border-color: #dee2e6;
    }

    /* Animations */
    @keyframes fadeUp {
        from { opacity: 0; transform: translateY(30px); }
        to   { opacity: 1; transform: translateY(0); }
    }
    @keyframes fadeDown {
        from { opacity: 0; transform: translateY(-20px); }
        to   { opacity: 1; transform: translateY(0); }
    }

    /* Custom Modal Styles (No Bootstrap) */
    .custom-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1200;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .custom-modal-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(2px);
    }

    .custom-modal-dialog {
        position: relative;
        margin: auto;
        max-width: 500px;
        width: 90%;
        max-height: 80vh;
        overflow: hidden;
    }

    .custom-modal-content {
        background: white;
        border-radius: 8px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        display: flex;
        flex-direction: column;
        height: 100%;
        max-height: 80vh;
    }

    .custom-modal-header {
        padding: 16px 20px;
        border-bottom: 1px solid #dee2e6;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .custom-modal-title {
        margin: 0;
        font-size: 1.25rem;
        font-weight: 500;
        color: #333;
    }

    .custom-modal-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: #6c757d;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: background-color 0.2s ease;
    }

    .custom-modal-close:hover {
        background-color: #f8f9fa;
        color: #000;
    }

    .custom-modal-body {
        padding: 20px;
        flex: 1;
        overflow-y: auto;
    }

    .custom-modal-footer {
        padding: 12px 20px;
        border-top: 1px solid #dee2e6;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }

    .custom-btn-secondary {
        background-color: #6c757d;
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.875rem;
        transition: background-color 0.2s ease;
    }

    .custom-btn-secondary:hover {
        background-color: #5a6268;
    }

    .clickable-item {
        padding: 12px;
        margin-bottom: 8px;
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        cursor: pointer;
        transition: all 0.2s ease;
        font-size: 0.95rem;
    }

    .clickable-item:hover {
        background-color: #e9ecef;
        border-color: #007bff;
        box-shadow: 0 2px 4px rgba(0,123,255,0.2);
    }

    .clickable-item:last-child {
        margin-bottom: 0;
    }
</style>

<div class="page-container">
    <h1 class="page-title">Status Peminjaman Saya</h1>

    <div class="cards-container">
        @forelse ($borrowings as $borrowing)
            <div class="card" id="card-{{ $borrowing->id }}" data-commodities='@json($borrowing->commodities->map(fn($c) => ["name" => $c->name, "quantity" => $c->pivot->quantity, "photo" => $c->photo])->values()->toArray())' data-items='@json($borrowing->items->where("status", "approved")->filter(fn($item) => $item->commodity)->map(fn($item) => ["id" => $item->id, "name" => $item->commodity->name])->values()->toArray())'>
                @if($borrowing->commodities->count() > 1)
                    <div class="slider" id="slider-{{ $borrowing->id }}">
                        <div class="slider-images" style="transform: translateX(0%);">
                            @foreach($borrowing->commodities as $index => $commodity)
                                @if($commodity->photo)
                                    <img src="{{ $commodity->photo }}" alt="{{ $commodity->name }}">
                                @else
                                    <div class="no-image"><i class="fas fa-camera"></i></div>
                                @endif
                            @endforeach
                        </div>
                        <div class="slider-controls">
                            <button class="slider-btn prev" onclick="prevCommodity('{{ $borrowing->id }}')"><i class="fas fa-arrow-left"></i></button>
                            <button class="slider-btn next" onclick="nextCommodity('{{ $borrowing->id }}')"><i class="fas fa-arrow-right"></i></button>
                        </div>
                    </div>
                    <div class="dots" id="dots-{{ $borrowing->id }}">
                        @foreach($borrowing->commodities as $index => $commodity)
                            <span class="dot {{ $index == 0 ? 'active' : '' }}" onclick="goToCommodity('{{ $borrowing->id }}', {{ $index }})"></span>
                        @endforeach
                    </div>
                    <div class="current-commodity" id="commodity-info-{{ $borrowing->id }}">
                        @php $first = $borrowing->commodities->first(); @endphp
                        <div class="commodity-name">{{ $first->name }} ({{ $first->pivot->quantity }} unit)</div>
                    </div>
                @else
                    @php
                        $firstCommodity = $borrowing->commodities->first();
                    @endphp
                    @if($firstCommodity)
                        @if($firstCommodity->photo)
                            <img src="{{ $firstCommodity->photo }}" alt="{{ $firstCommodity->name }}">
                        @else
                            <div class="no-image"><i class="fas fa-camera"></i></div>
                        @endif
                        <div class="current-commodity">
                            <div class="commodity-name">{{ $firstCommodity->name }} ({{ $firstCommodity->pivot->quantity }} unit)</div>
                        </div>
                    @else
                        <div class="no-image"><i class="fas fa-camera"></i></div>
                        <div class="current-commodity">
                            <div class="commodity-name">Tidak ada barang</div>
                        </div>
                    @endif
                @endif

                <div class="info-text"><i class="fas fa-file-alt"></i> <b>Tujuan:</b> {{ $borrowing->tujuan ?? '-' }}</div>
                <div class="info-text"><i class="fas fa-calendar"></i> <b>Tanggal Pengembalian:</b> {{ $borrowing->full_return_datetime ? $borrowing->full_return_datetime->format('d M Y H:i') : '-' }}</div>
                <div class="info-text"><i class="fas fa-calendar"></i> <b>Tanggal Peminjaman:</b> {{ $borrowing->full_borrow_datetime ? $borrowing->full_borrow_datetime->format('d M Y H:i') : '-' }}</div>

                @if ($borrowing->status === 'approved' || $borrowing->status === 'partially_approved' || $borrowing->status === 'partial')
                    <div class="status-ongoing">Sedang dalam peminjaman</div>
                @elseif ($borrowing->status === 'returned' || $borrowing->status === 'partially_returned')
                    <div class="status-returned">Sudah Dikembalikan</div>
                    @if($borrowing->return_photo)
                        <a href="{{ asset('storage/' . str_replace('\\', '/', $borrowing->return_photo)) }}" target="_blank" class="btn btn-sm btn-info" style="margin-top: 8px; display: inline-block;">Lihat Foto Pengembalian</a>
                    @endif
                @elseif ($borrowing->status === 'rejected')
                    <span class="status-rejected">Ditolak</span>
                @else
                    <span class="text-muted">Menunggu Persetujuan</span>
                @endif

                <div class="item-statuses" style="margin-top: 12px; padding: 10px; background: #f8f9fa; border-radius: 8px; font-size: 0.85rem;">
                    <div style="font-weight: 600; margin-bottom: 8px; color: #333;">Status Barang:</div>
                    @forelse ($borrowing->items as $item)
                        @if($item->commodity)
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                <span style="font-weight: 500;">{{ $item->commodity->name }}</span>
                                <span class="badge {{ $item->status === 'approved' ? 'bg-success' : ($item->status === 'rejected' ? 'bg-danger' : ($item->status === 'returned' ? 'bg-info' : 'bg-warning')) }}">
                                    {{ ucfirst($item->status) }}
                                </span>
                            </div>
                        @endif
                    @empty
                        <span class="text-muted">Tidak ada barang.</span>
                    @endforelse
                </div>

                <div style="display: flex; gap: 10px; margin-top: auto;">
                    <a href="{{ route('officers.borrowings.show', $borrowing->id) }}" class="btn-primary" style="flex: 1; text-align: center;">Detail</a>
                    @if (($borrowing->status === 'approved' || $borrowing->status === 'partially_approved' || $borrowing->status === 'partial') && $borrowing->items->where('status', 'approved')->count() > 0)
                        <button type="button" class="btn-primary" onclick="openReturnModal({{ $borrowing->id }})" style="flex: 1; text-align: center; width: 100%; border: none; padding: 8px 16px; background: #007bff; color: white; border-radius: 12px; cursor: pointer; font-weight: 700; font-size: 0.9rem; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">Kembalikan</button>
                    @endif
                </div>
            </div>
        @empty
            <p>Tidak ada pengajuan peminjaman.</p>
        @endforelse
    </div>

    <div class="pagination-container">
        <div class="entries-info">
            Showing {{ $borrowings->firstItem() }} to {{ $borrowings->lastItem() }} of {{ $borrowings->total() }} entries
        </div>
        <ul class="pagination">
            @if ($borrowings->onFirstPage())
                <li class="disabled"><span>Previous</span></li>
            @else
                <li><a href="{{ $borrowings->previousPageUrl() }}">Previous</a></li>
            @endif

            @foreach ($borrowings->onEachSide(1)->links()->elements as $element)
                @if (is_string($element))
                    <li class="disabled"><span>{{ $element }}</span></li>
                @endif

                @if (is_array($element))
                    @foreach ($element as $page => $url)
                        @if ($page == $borrowings->currentPage())
                            <li class="active"><span>{{ $page }}</span></li>
                        @else
                            <li><a href="{{ $url }}">{{ $page }}</a></li>
                        @endif
                    @endforeach
                @endif
            @endforeach

            @if ($borrowings->hasMorePages())
                <li><a href="{{ $borrowings->nextPageUrl() }}">Next</a></li>
            @else
                <li class="disabled"><span>Next</span></li>
            @endif
        </ul>
    </div>
</div>

<!-- Custom Modal for selecting items to return (No Bootstrap) -->
<div id="returnModal" class="custom-modal" style="display: none;">
    <div class="custom-modal-overlay" onclick="closeReturnModal()"></div>
    <div class="custom-modal-dialog">
        <div class="custom-modal-content">
            <div class="custom-modal-header">
                <h5 class="custom-modal-title">Pilih Barang untuk Dikembalikan</h5>
                <button type="button" class="custom-modal-close" onclick="closeReturnModal()">&times;</button>
            </div>
            <div class="custom-modal-body">
                <div id="itemsList">
                    <!-- Items will be populated here -->
                </div>
            </div>
            <div class="custom-modal-footer">
                <button type="button" class="custom-btn-secondary" onclick="closeReturnModal()">Batal</button>
            </div>
        </div>
    </div>
</div>

<style>
    /* Custom Modal Styles (No Bootstrap) */
    .custom-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1200;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .custom-modal-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(2px);
    }

    .custom-modal-dialog {
        position: relative;
        margin: auto;
        max-width: 500px;
        width: 90%;
        max-height: 80vh;
        overflow: hidden;
    }

    .custom-modal-content {
        background: white;
        border-radius: 8px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        display: flex;
        flex-direction: column;
        height: 100%;
        max-height: 80vh;
    }

    .custom-modal-header {
        padding: 16px 20px;
        border-bottom: 1px solid #dee2e6;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .custom-modal-title {
        margin: 0;
        font-size: 1.25rem;
        font-weight: 500;
        color: #333;
    }

    .custom-modal-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: #6c757d;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: background-color 0.2s ease;
    }

    .custom-modal-close:hover {
        background-color: #f8f9fa;
        color: #000;
    }

    .custom-modal-body {
        padding: 20px;
        flex: 1;
        overflow-y: auto;
    }

    .custom-modal-footer {
        padding: 12px 20px;
        border-top: 1px solid #dee2e6;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }

    .custom-btn-secondary {
        background-color: #6c757d;
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.875rem;
        transition: background-color 0.2s ease;
    }

    .custom-btn-secondary:hover {
        background-color: #5a6268;
    }

    .clickable-item {
        padding: 12px;
        margin-bottom: 8px;
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        cursor: pointer;
        transition: all 0.2s ease;
        font-size: 0.95rem;
    }

    .clickable-item:hover {
        background-color: #e9ecef;
        border-color: #007bff;
        box-shadow: 0 2px 4px rgba(0,123,255,0.2);
    }

    .clickable-item:last-child {
        margin-bottom: 0;
    }
</style>

<script>
    function updateSlider(cardId, newIndex) {
        const card = document.getElementById('card-' + cardId);
        const slider = document.getElementById('slider-' + cardId);
        const sliderImages = slider.querySelector('.slider-images');

        sliderImages.style.transform = `translateX(-${newIndex * 100}%)`;

        slider.dataset.index = newIndex;

        // Update dots
        const dots = document.querySelectorAll('#dots-' + cardId + ' .dot');
        dots.forEach((dot, index) => {
            dot.classList.toggle('active', index === newIndex);
        });

        // Update commodity info
        const commodities = JSON.parse(card.dataset.commodities);
        const currentCommodity = commodities[newIndex];
        const infoDiv = document.getElementById('commodity-info-' + cardId);
        infoDiv.innerHTML = `<div class="commodity-name">${currentCommodity.name} (${currentCommodity.quantity} unit)</div>`;
    }

    function nextCommodity(cardId) {
        const slider = document.getElementById('slider-' + cardId);
        const images = slider.querySelectorAll('.slider-images img, .slider-images .no-image');
        const total = images.length;
        let currentIndex = slider.dataset.index ? parseInt(slider.dataset.index) : 0;
        currentIndex = (currentIndex + 1) % total;
        updateSlider(cardId, currentIndex);
        updateButtons(cardId, currentIndex, total);
    }

    function prevCommodity(cardId) {
        const slider = document.getElementById('slider-' + cardId);
        const images = slider.querySelectorAll('.slider-images img, .slider-images .no-image');
        const total = images.length;
        let currentIndex = slider.dataset.index ? parseInt(slider.dataset.index) : 0;
        currentIndex = (currentIndex - 1 + total) % total;
        updateSlider(cardId, currentIndex);
        updateButtons(cardId, currentIndex, total);
    }

    function updateButtons(cardId, currentIndex, total) {
        const prevBtn = document.querySelector(`#card-${cardId} .slider-btn.prev`);
        const nextBtn = document.querySelector(`#card-${cardId} .slider-btn.next`);

        if (total > 1) {
            prevBtn.style.display = 'inline-block';
            nextBtn.style.display = 'inline-block';
        } else {
            prevBtn.style.display = 'none';
            nextBtn.style.display = 'none';
        }
    }

    function goToCommodity(cardId, index) {
        const slider = document.getElementById('slider-' + cardId);
        const images = slider.querySelectorAll('.slider-images img, .slider-images .no-image');
        const total = images.length;
        updateSlider(cardId, index);
        updateButtons(cardId, index, total);
    }

    function openReturnModal(borrowingId) {
        const card = document.getElementById(`card-${borrowingId}`);
        const itemsData = JSON.parse(card.dataset.items || '[]');
        console.log('Borrowing ID:', borrowingId);
        console.log('Items Data from dataset:', itemsData);
        if (itemsData.length === 0) {
            alert('Tidak ada barang yang dapat dikembalikan saat ini.');
            return;
        }
        const itemsList = document.getElementById('itemsList');
        itemsList.innerHTML = '';
        itemsData.forEach(item => {
            const div = document.createElement('div');
            div.className = 'clickable-item';
            div.dataset.itemId = item.id;
            div.innerHTML = `<span>${item.name}</span>`;
            div.addEventListener('click', function() {
                closeReturnModal();
                let url = '{{ route("officers.borrowings.return.item", ":itemId") }}'.replace(':itemId', this.dataset.itemId);
                window.location.href = url;
            });
            itemsList.appendChild(div);
        });
        const modalElement = document.getElementById('returnModal');
        modalElement.dataset.borrowingId = borrowingId;
        modalElement.style.display = 'flex';
    }

    function closeReturnModal() {
        const modalElement = document.getElementById('returnModal');
        modalElement.style.display = 'none';
    }

    document.addEventListener('DOMContentLoaded', function() {
        @forelse ($borrowings as $borrowing)
            @if($borrowing->commodities->count() > 1)
                const slider{{ $borrowing->id }} = document.getElementById('slider-{{ $borrowing->id }}');
                slider{{ $borrowing->id }}.dataset.index = '0';
                updateButtons('{{ $borrowing->id }}', 0, {{ $borrowing->commodities->count() }});
            @endif
        @empty
        @endforelse
    });
</script>
@endsection
