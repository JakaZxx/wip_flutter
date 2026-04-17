@extends('layouts.app')

@section('title', 'Data Barang')

@section('content')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
/* Animasi fade in */
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}
.fade-seq { opacity: 0; animation: fadeInUp 0.5s ease forwards; }

/* Container */
.container-custom {
    background: #fff; max-width: 1200px; margin: 40px auto; padding: 25px;
    border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden;
}
.container-custom h1 { font-size: 24px; font-weight: 600; margin-bottom: 20px; color: #333; }

/* Tombol Tambah */
.btn-cust { display: inline-flex; align-items: center; color: #fff; padding: 8px 14px; border-radius: 6px; text-decoration: none; font-size: 13px; font-weight: 500; border: none; cursor: pointer; transition: background-color 0.2s; }
.btn-cust i { padding-right: 6px; font-size: 16px; }
.btn-add { background: #28a745; } .btn-add:hover { background-color: #218838; }
.btn-import { background: #17a2b8; } .btn-import:hover { background-color: #138496; }
.btn-search { background: #17a2b8; } .btn-search:hover { background-color: #138496; }

/* View All Button */
.btn-view-all {
    position: relative; display: inline-flex; align-items: center; padding: 8px 14px;
    border-radius: 6px; color: #fff; font-size: 13px; font-weight: 500; text-decoration: none;
    overflow: hidden; z-index: 1; background: #6f42c1;
}
.btn-view-all::before {
    content: ""; position: absolute; inset: 0;
    background: linear-gradient(90deg,#6f42c1,#5a32a3); transition: opacity 0.4s; z-index: -1;
}
.btn-view-all:hover::before { background: linear-gradient(90deg,#5a32a3,#6f42c1); opacity: 0.8; }
.btn-view-all i { margin-right: 6px; }

/* Search + Filter */
.filter-container {
    display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 20px; align-items: center;
}
.filter-container input, .filter-container select {
    padding: 8px 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px;
}
.btn-search { display: inline-flex; align-items: center; background: #007bff; color: #fff; padding: 8px 14px; border-radius: 6px; text-decoration: none; font-size: 13px; font-weight: 500; border: none; cursor: pointer; transition: background-color 0.2s; }
.btn-search:hover { background-color: #0056b3; }

/* Card Grid */
.assets-grid {
    display: grid; grid-template-columns: repeat(auto-fill,minmax(300px,1fr)); gap: 20px; margin-bottom: 30px;
}
.asset-card {
    background: linear-gradient(145deg,#fff 0%,#f8f9fa 100%); border-radius: 16px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08),0 2px 4px rgba(0,0,0,0.04);
    overflow: hidden; transition: all 0.3s cubic-bezier(0.4,0,0.2,1);
    border: 1px solid #e9ecef; position: relative;
}
.asset-card::before {
    content: ""; position: absolute; top: 0; left: 0; right: 0; height: 3px;
    background: linear-gradient(90deg,#6f42c1 0%,#ffc107 50%,#28a745 100%);
    opacity: 0; transition: opacity 0.3s ease;
}
.asset-card:hover { transform: translateY(-8px) scale(1.02); box-shadow: 0 12px 30px rgba(0,0,0,0.15),0 6px 12px rgba(0,0,0,0.1); }
.asset-card:hover::before { opacity: 1; }

.asset-photo {
    height: 200px; background: linear-gradient(135deg,#f8f9fa 0%,#e9ecef 100%);
    display: flex; align-items: center; justify-content: center; overflow: hidden;
    position: relative; transition: all 0.3s ease;
}
.asset-photo::before {
    content: ""; position: absolute; inset: 0;
    background: linear-gradient(45deg,rgba(111,66,193,0.1) 0%,rgba(255,193,7,0.1) 100%);
    opacity: 0; transition: opacity 0.3s ease; z-index: 1;
}
.asset-card:hover .asset-photo::before { opacity: 1; }
.asset-photo img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s ease; }
.asset-card:hover .asset-photo img { transform: scale(1.05); }
.asset-photo .no-photo { font-size: 48px; color: #dee2e6; transition: all 0.3s ease; z-index: 2; position: relative; }
.asset-card:hover .asset-photo .no-photo { color: #adb5bd; transform: scale(1.1); }

.asset-info { padding: 20px; }
.asset-name { font-size: 18px; font-weight: 600; color: #333; margin-bottom: 8px; line-height: 1.3; }
.asset-code { font-size: 14px; color: #6c757d; margin-bottom: 12px; font-family: 'Courier New', monospace; }
.asset-details {
    display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 18px;
    font-size: 13px; padding: 15px 0; border-top: 1px solid #f1f3f4; border-bottom: 1px solid #f1f3f4;
}
.detail-item { display: flex; flex-direction: column; padding: 8px 0; }
.detail-label { font-weight: 600; color: #495057; font-size: 10px; text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 4px; display: flex; align-items: center; gap: 4px; }
.detail-value { color: #212529; font-weight: 500; font-size: 13px; line-height: 1.4; }

.stock-badge { display: inline-flex; align-items: center; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
.stock-low { background: #fff3cd; color: #856404; }
.stock-out { background: #f8d7da; color: #721c24; }
.stock-good { background: #d1e7dd; color: #0f5132; }

.card-actions {  margin-top: auto; display: flex; align-items: center; justify-content: space-between; background-color: #f8f9fa; padding: 12px 18px; border-top: 1px solid #e9ecef; }

.btn-detail { background: #007bff; color: white; padding: 6px 24px; border-radius: 6px; border: none; font-size: 12px; font-weight: 600; cursor: pointer; transition: background-color 0.2s; }
.btn-detail:hover { background-color: #0056b3; }
.btn-edit { background: #ffc107; color: #333; padding: 6px 12px; border-radius: 6px; border: none; font-size: 12px; font-weight: 600; cursor: pointer; transition: background-color 0.2s; }
.btn-edit:hover { background-color: #e0a800; }
.btn-delete { background: #dc3545; color: white; padding: 6px 12px; border-radius: 6px; border: none; font-size: 12px; font-weight: 600; cursor: pointer; transition: background-color 0.2s; }
.btn-delete:hover { background-color: #c82333; }

/* Footer tabel */
.pagination-container {
    display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; margin-top: 15px; gap: 10px;
}
.entries-info { font-size: 13px; color: #555; }
.pagination { list-style: none; display: flex; gap: 4px; padding: 0; margin: 0; }
.pagination li { display: inline-block; }
.pagination a, .pagination span {
    padding: 4px 8px; border: 1px solid #ddd; border-radius: 6px; font-size: 12px; color: #333; text-decoration: none; transition: all 0.2s;
}
.pagination a:hover { background-color: #007bff; color: #fff; border-color: #007bff; }
.pagination .active span { background-color: #007bff; color: #fff; border-color: #007bff; }
.pagination .disabled span { color: #aaa; background: #f9f9f9; cursor: not-allowed; }

/* Modal Styles */
.modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
.modal.show { display: flex; align-items: center; justify-content: center; }
.modal-content {
    background: #fff; border-radius: 12px; width: 90%; max-width: 600px; max-height: 90vh; overflow-y: auto;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
}
.modal-header { padding: 20px 25px; border-bottom: 1px solid #e9ecef; display: flex; justify-content: space-between; align-items: center; }
.modal-title { font-size: 20px; font-weight: 600; color: #333; }
.close { font-size: 24px; color: #6c757d; cursor: pointer; background: none; border: none; }
.modal-body { padding: 25px; }
.modal-photo {
    width: 100%; height: 250px; background: #f8f9fa; border-radius: 8px; display: flex; align-items: center; justify-content: center;
    margin-bottom: 20px; overflow: hidden;
}
.modal-photo img { width: 100%; height: 100%; object-fit: cover; }
.modal-details { display: flex; flex-direction: column; gap: 25px; }
.modal-detail-group {
    background: transparent; padding: 0; border-radius: 0; border-bottom: 1px solid #e9ecef; padding-bottom: 20px;
}
.modal-detail-group:last-child { border-bottom: none; padding-bottom: 0; }
.modal-detail-group h4 {
    font-size: 16px; font-weight: 600; color: #333; margin-bottom: 15px;
    text-transform: uppercase; letter-spacing: 0.8px; display: flex; align-items: center; gap: 8px;
}
.modal-detail-group h4::before { content: ""; width: 4px; height: 16px; background: linear-gradient(135deg,#007bff,#0056b3); border-radius: 2px; }
.modal-detail-item { margin-bottom: 8px; display: flex; justify-content: space-between; }
.modal-detail-label { font-weight: 500; color: #6c757d; }
.modal-detail-value { font-weight: 600; color: #333; }
.modal-actions { display: flex; gap: 10px; margin-top: 25px; padding-top: 20px; border-top: 1px solid #e9ecef; }
.modal-btn { flex: 1; padding: 10px 15px; border: none; border-radius: 6px; font-weight: 500; cursor: pointer; transition: all 0.2s; }
.modal-btn-edit { background: #ffc107; color: #000; } .modal-btn-edit:hover { background: #e0a800; }
.modal-btn-delete { background: #dc3545; color: #fff; } .modal-btn-delete:hover { background: #c82333; }
.modal-btn-close { background: #6c757d; color: #fff; } .modal-btn-close:hover { background: #5a6268; }

/* View All Mode Indicator */
.view-all-indicator {
    background: linear-gradient(135deg,#667eea 0%,#764ba2 100%); color: white; padding: 8px 15px; border-radius: 20px;
    font-size: 12px; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; margin-bottom: 15px;
}

/* Responsive Design */
@media (max-width: 768px) {
    .container-custom { margin: 20px auto; padding: 15px; }
    .assets-grid { grid-template-columns: 1fr; gap: 15px; }
    .asset-photo { height: 180px; }
    .asset-info { padding: 15px; }
    .asset-name { font-size: 16px; }
    .asset-details { grid-template-columns: 1fr; }
    .btn-detail { margin-bottom: 8px; }
    .btn-search { width: 80px;}
    .pagination-container { flex-direction: column; align-items: center; }
    .filter-container { flex-direction: column; align-items: stretch; }
    .modal-content { width: 95%; margin: 20px; }
    .modal-details { grid-template-columns: 1fr; }
}

/* ===================== */
/* Import Data Barang CSS*/
/* ===================== */
#import-commodities-form {
    background: #fdfdfd; padding: 25px; border-radius: 12px; margin-bottom: 20px;
    border: 1px solid #e0e6ed; box-shadow: 0 4px 12px rgba(0,0,0,0.05); animation: fadeInUp 0.4s ease;
}
#import-commodities-form h5 {
    font-size: 16px; font-weight: 600; margin-bottom: 18px; color: #333;
    display: flex; align-items: center; gap: 8px;
}
#import-commodities-form h5::before {
    content: "\f56f"; font-family: "Font Awesome 6 Free"; font-weight: 900; color: #007bff; font-size: 16px;
}
#import-commodities-form .form-label { font-weight: 500; font-size: 13px; color: #555; margin-bottom: 6px; display: block; }
#import-commodities-form .form-control {
    padding: 10px; font-size: 13px; border: 1px solid #ced4da; border-radius: 8px;
    transition: border-color 0.2s, box-shadow 0.2s;
}
#import-commodities-form .form-control:focus { border-color: #007bff; box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.15); outline: none; }

/* Tombol dalam import */
#import-commodities-form .btn {
    display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px;
    border-radius: 8px; font-size: 13px; font-weight: 500; cursor: pointer;
    border: none; transition: all 0.2s ease;
}
#import-commodities-form .btn-success { background: linear-gradient(90deg,#28a745,#20c997); color: #fff; }
#import-commodities-form .btn-success:hover { background: linear-gradient(90deg,#218838,#1e7e34); }
#import-commodities-form .btn-secondary { background: #6c757d; color: #fff; }
#import-commodities-form .btn-secondary:hover { background: #5a6268; }

/* Hint format */
#import-commodities-form small { font-size: 12px; color: #6c757d; margin-top: 10px; display: block; line-height: 1.4; }

/* Responsif */
@media (max-width: 768px) {
    #import-commodities-form { padding: 15px; }
    #import-commodities-form h5 { font-size: 15px; }
}
</style>


<div class="container-custom">
    <h1 class="fade-seq" style="animation-delay: 0.1s;">Kelola Aset</h1>



    <div style="display: flex; gap: 10px; margin-bottom: 15px; flex-wrap: wrap;">
        <a href="{{ route('officers.assets.create') }}" class=" btn-cust btn-add fade-seq" style="animation-delay: 0.2s;">
            <i class="fas fa-plus"></i> Tambah Barang
        </a>

        <button type="button" class=" btn-cust btn-import fade-seq" onclick="document.getElementById('import-commodities-form').style.display='block'">
            <i class="fas fa-upload"></i> Import Barang
        </button>
    </div>

    <!-- Search & Filter -->
    <form method="GET" action="{{ route('officers.assets.index') }}" class="filter-container fade-seq" style="animation-delay: 0.3s;">
        <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama / kode barang...">
        <button type="submit" class="btn-cust btn-search fade-seq">
            <i class="fas fa-search"></i> Cari
        </button>
    </form>

    <!-- Import -->
    <div id="import-commodities-form" style="display: none; background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #dee2e6;">
        <h5 style="margin-bottom: 15px; color: #333;">Import Data Barang</h5>
        <form action="{{ route('officers.import.assets') }}" method="POST" enctype="multipart/form-data">
            @csrf
            <div class="mb-3">
                <label for="commodities_file" class="form-label">Pilih File Excel</label>
                <input type="file" class="form-control" id="commodities_file" name="file" accept=".xlsx,.csv" required>
            </div>
            <div style="display: flex; gap: 10px;">
                <button type="submit" class="btn btn-success">
                    <i class="fas fa-upload"></i> Import
                </button>
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('import-commodities-form').style.display='none'">
                    <i class="fas fa-times"></i> Batal
                </button>
            </div>
        </form>
        <small class="text-muted mt-2 d-block">
            Format: kode_barang, nama_barang, merk, harga_satuan, sumber, tahun, deskripsi, stok, kondisi, lokasi, jurusan
        </small>
    </div>

    <!-- Assets Grid -->
    @if($assets->count() > 0)
        <div class="assets-grid fade-seq" style="animation-delay: 0.4s;">
            @foreach($assets as $index => $asset)
                <div class="asset-card fade-seq" style="animation-delay: {{ 0.5 + ($index * 0.1) }}s;">
                    <div class="asset-photo">
                        @if($asset->photo_url)
                            <img src="{{ $asset->photo_url }}" alt="{{ $asset->name }}">
                        @else
                            <i class="fas fa-box no-photo"></i>
                        @endif
                    </div>

                    <div class="asset-info">
                        <div class="asset-name">{{ $asset->name }}</div>
                        <div class="asset-code">{{ $asset->code }}</div>

                        <div class="asset-details">
                            <div class="detail-item">
                                <div class="detail-label">
                                    <i class="fas fa-cubes"></i> Stok
                                </div>
                                <div class="detail-value">
                                    <span class="stock-badge {{ $asset->stock <= 0 ? 'stock-out' : ($asset->stock <= 5 ? 'stock-low' : 'stock-good') }}">
                                        {{ $asset->stock }} unit
                                    </span>
                                </div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">
                                    <i class="fas fa-map-marker-alt"></i> Lokasi
                                </div>
                                <div class="detail-value">{{ $asset->lokasi }}</div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">
                                    <i class="fas fa-graduation-cap"></i> Jurusan
                                </div>
                                <div class="detail-value">{{ $asset->jurusan }}</div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">
                                    <i class="fas fa-wrench"></i> Kondisi
                                </div>
                                <div class="detail-value">{{ $asset->condition }}</div>
                            </div>
                        </div>

                        <div class="card-actions">
                            <button class="btn-detail" onclick="showAssetDetail({{ $asset->id }})">
                                <i class="fas fa-eye"></i> Detail
                            </button>
                            <div class="btn-action" style="display: flex; gap: 8px;">
                            <a href="{{ route('officers.assets.edit', $asset->id) }}" class="btn-edit" title="Edit">
                                <i class="fas fa-edit"></i>
                            </a>
                            <form action="{{ route('officers.assets.destroy', $asset->id) }}" method="POST" class="form-delete">
                                @csrf
                                @method('DELETE')
                                <button type="button" class="btn-delete btn-confirm" title="Hapus">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                            </div>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>

        <!-- Pagination -->
        <div class="pagination-container">
            <div class="entries-info">
                Showing {{ $assets->firstItem() }} to {{ $assets->lastItem() }} of {{ $assets->total() }} entries
            </div>
            <ul class="pagination">
                @if ($assets->onFirstPage())
                    <li class="disabled"><span>Previous</span></li>
                @else
                    <li><a href="{{ $assets->appends(request()->query())->previousPageUrl() }}">Previous</a></li>
                @endif

                @foreach ($assets->onEachSide(1)->links()->elements as $element)
                    @if (is_string($element))
                        <li class="disabled"><span>{{ $element }}</span></li>
                    @endif

                    @if (is_array($element))
                        @foreach ($element as $page => $url)
                            @if ($page == $assets->currentPage())
                                <li class="active"><span>{{ $page }}</span></li>
                            @else
                                <li><a href="{{ $url . (strpos($url, '?') !== false ? '&' : '?') . http_build_query(request()->query()) }}">{{ $page }}</a></li>
                            @endif
                        @endforeach
                    @endif
                @endforeach

                @if ($assets->hasMorePages())
                    <li><a href="{{ $assets->appends(request()->query())->nextPageUrl() }}">Next</a></li>
                @else
                    <li class="disabled"><span>Next</span></li>
                @endif
            </ul>
        </div>
    @else
        <div class="fade-seq" style="animation-delay: 0.4s; text-align: center; padding: 60px 20px; color: #6c757d;">
            <i class="fas fa-box-open" style="font-size: 64px; margin-bottom: 20px; opacity: 0.5;"></i>
            <h3 style="margin-bottom: 10px; color: #495057;">Tidak ada barang ditemukan</h3>
            <p>Coba ubah kriteria pencarian</p>
        </div>
    @endif
</div>

<!-- Asset Detail Modal -->
<div id="assetModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title">Detail Barang</h3>
            <button type="button" class="close" onclick="closeAssetModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div id="modalContent">
                <!-- Content will be loaded here -->
            </div>
        </div>
    </div>
</div>

<script>
    // Modal functions
    function showAssetDetail(assetId) {
        const modal = document.getElementById('assetModal');
        const modalContent = document.getElementById('modalContent');

        // Show loading state
        modalContent.innerHTML = `
            <div style="text-align: center; padding: 40px;">
                <i class="fas fa-spinner fa-spin" style="font-size: 32px; color: #6c757d; margin-bottom: 15px;"></i>
                <p>Memuat detail barang...</p>
            </div>
        `;

        modal.classList.add('show');

        // Fetch asset details
        fetch(`/officers/assets/${assetId}/detail`)
            .then(response => {
                if (!response.ok) {
                    // If response is not OK (e.g., 404, 500), try to parse JSON error or throw generic error
                    return response.json().then(errorData => {
                        throw new Error(errorData.message || 'Gagal memuat detail aset.');
                    }).catch(() => {
                        throw new Error('Terjadi kesalahan server atau aset tidak ditemukan.');
                    });
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    displayAssetDetail(data.asset);
                } else {
                    modalContent.innerHTML = `
                        <div style="text-align: center; padding: 40px; color: #dc3545;">
                            <i class="fas fa-exclamation-triangle" style="font-size: 48px; margin-bottom: 15px;"></i>
                            <h4>Gagal memuat detail</h4>
                            <p>${data.message || 'Terjadi kesalahan saat memuat data'}</p>
                        </div>
                    `;
                }
            })
            .catch(error => {
                modalContent.innerHTML = `
                    <div style="text-align: center; padding: 40px; color: #dc3545;">
                        <i class="fas fa-exclamation-triangle" style="font-size: 48px; margin-bottom: 15px;"></i>
                        <h4>Kesalahan</h4>
                        <p>${error.message || 'Gagal terhubung ke server. Silakan coba lagi.'}</p>
                    </div>
                `;
            });
    }

    function displayAssetDetail(asset) {
        const modalContent = document.getElementById('modalContent');

        const stockBadgeClass = asset.stock <= 0 ? 'stock-out' : (asset.stock <= 5 ? 'stock-low' : 'stock-good');

        modalContent.innerHTML = `
            <div class="modal-photo">
                ${asset.photo_url ?
                    `<img src="${asset.photo_url}" alt="${asset.name}">` :
                    `<i class="fas fa-box" style="font-size: 64px; color: #dee2e6;"></i>`
                }
            </div>

            <div class="modal-details">
                <div class="modal-detail-group">
                    <h4>Informasi Dasar</h4>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Nama Barang:</span>
                        <span class="modal-detail-value">${asset.name}</span>
                    </div>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Kode Barang:</span>
                        <span class="modal-detail-value" style="font-family: 'Courier New', monospace;">${asset.code}</span>
                    </div>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Stok:</span>
                        <span class="modal-detail-value">
                            <span class="stock-badge ${stockBadgeClass}">${asset.stock} unit</span>
                        </span>
                    </div>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Kondisi:</span>
                        <span class="modal-detail-value">${asset.condition}</span>
                    </div>
                </div>

                <div class="modal-detail-group">
                    <h4>Lokasi & Jurusan</h4>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Lokasi:</span>
                        <span class="modal-detail-value">${asset.lokasi}</span>
                    </div>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Jurusan:</span>
                        <span class="modal-detail-value">${asset.jurusan}</span>
                    </div>
                </div>

                <div class="modal-detail-group">
                    <h4>Spesifikasi</h4>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Merk:</span>
                        <span class="modal-detail-value">${asset.merk || 'Tidak ada'}</span>
                    </div>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Sumber:</span>
                        <span class="modal-detail-value">${asset.sumber}</span>
                    </div>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Tahun:</span>
                        <span class="modal-detail-value">${asset.tahun}</span>
                    </div>
                    <div class="modal-detail-item">
                        <span class="modal-detail-label">Harga Satuan:</span>
                        <span class="modal-detail-value">Rp ${new Intl.NumberFormat('id-ID').format(asset.harga_satuan)}</span>
                    </div>
                </div>

                <div class="modal-detail-group" style="grid-column: 1 / -1;">
                    <h4>Deskripsi</h4>
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-top: 10px;">
                        <p style="margin: 0; line-height: 1.6; color: #333;">
                            ${asset.deskripsi || 'Tidak ada deskripsi'}
                        </p>
                    </div>
                </div>
            </div>
        `;
    }

    function closeAssetModal() {
        const modal = document.getElementById('assetModal');
        modal.classList.remove('show');
    }

    // Close modal when clicking outside
    document.getElementById('assetModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeAssetModal();
        }
    });

    // Close modal with Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeAssetModal();
        }
    });

    document.addEventListener('DOMContentLoaded', function() {
        const deleteButtons = document.querySelectorAll('.btn-confirm');
        deleteButtons.forEach(button => {
            button.addEventListener('click', function() {
                const form = this.closest('form');
                Swal.fire({
                    title: 'Yakin mau hapus?',
                    text: "Data yang dihapus tidak bisa dikembalikan!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Ya, hapus!',
                    cancelButtonText: 'Batal'
                }).then((result) => {
                    if (result.isConfirmed) {
                        form.submit();
                    }
                });
            });
        });

        @if(session('success'))
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: '{{ session('success') }}',
                showConfirmButton: false,
                timer: 2500
            });
        @endif

        @if(session('error'))
            Swal.fire({
                icon: 'error',
                title: 'Gagal!',
                text: '{{ session('error') }}',
                showConfirmButton: false,
                timer: 3500
            });
        @endif
    });
</script>
@endsection