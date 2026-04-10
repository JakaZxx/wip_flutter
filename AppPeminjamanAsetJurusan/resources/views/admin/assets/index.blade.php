@extends('layouts.app')

@section('title', 'Kelola Aset')

@section('content')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="stylesheet" href="{{ asset('css/admin-assets.css') }}">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<div class="container-custom">
    <h1 class="fade-up">
        @if(!empty($viewAll))
            Kelola Aset (Mode: Lihat Semua)
        @else
            Kelola Aset
        @endif
    </h1>
    @if(empty($viewAll))
        <a class="fade-up" href="{{ route('admin.assets.selectJurusan') }}"
           style="position: absolute; top: 58px; right: 27px; color: white; background-color: red; border-radius: 50%; width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; font-weight: bold; text-decoration: none; font-size: 18px; line-height: 1; cursor: pointer;"
           title="Pilih Jurusan Lain">
            &times;
        </a>
    @else
        <a class="fade-up" href="{{ route('admin.assets.selectJurusan') }}"
           style="position: absolute; top: 58px; right: 27px; color: white; background-color: #007bff; border-radius: 50%; width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; font-weight: bold; text-decoration: none; font-size: 14px; line-height: 1; cursor: pointer;"
           title="Pilih Jurusan">
            <i class="fas fa-filter"></i>
        </a>
    @endif

    <div style="display: flex; gap: 10px; margin-bottom: 15px;">
        <a href="{{ route('admin.assets.create') }}" class="btn-add btn-cust fade-up">
            <i class="fas spc fa-plus"></i> Tambah Barang
        </a>

        <button type="button" class="btn-import btn-cust fade-up" onclick="document.getElementById('import-commodities-form').style.display='block'">
            <i class="fas spc fa-upload"></i> Import Barang
        </button>

        <a href="{{ route('admin.assets.index', ['view_all' => '1']) }}" class="btn-see btn-cust fade-up">
            <i class="fas spc fa-eye"></i> Lihat Semua Barang
        </a>
    </div>

    <!-- Search & Filter -->
    <form method="GET" action="{{ route('admin.assets.index') }}" class="filter-container fade-up">
        <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama / kode barang...">

        <select name="jurusan" onchange="this.form.submit()">
            <option value="">Semua Jurusan</option>
            @foreach($jurusanList as $jurusan)
                <option value="{{ $jurusan }}" {{ request('jurusan') == $jurusan ? 'selected' : '' }}>
                    {{ $jurusan }}
                </option>
            @endforeach
        </select>

        @if(!empty($viewAll))
            <input type="hidden" name="view_all" value="1">
            <div style="padding: 8px 12px; background: #e9ecef; border-radius: 6px; font-size: 13px; color: #495057;">
                <i class="fas fa-eye"></i> Mode: Lihat Semua Barang
            </div>
        @endif

        <button type="submit" class="btn-search">
            <i class="fas spc fa-search"></i> Cari
        </button>
    </form>

    <!-- Import Form -->
    <div id="import-commodities-form">
        <h5 style="margin-bottom: 15px; color: #333;"><i class="fas fa-upload"></i> Import Data Barang</h5>
        <form action="{{ route('admin.import.assets') }}" method="POST" enctype="multipart/form-data">
            @csrf
            <div class="mb-3">
                <label for="commodities_file" class="form-label">Pilih File Excel</label>
                <input type="file" class="form-control" id="commodities_file" name="file" accept=".xlsx,.csv" required>
            </div>
            <div style="display: flex; gap: 10px;">
                <button type="submit" class="btn btn-success">
                    <i class="fas fa-upload"></i> Import
                </button>
                <button type="button" class="btn-import-form" onclick="document.getElementById('import-commodities-form').style.display='none'">
                    <i class="fas fa-times"></i> Batal
                </button>
            </div>
        </form>
        <small class="text-muted mt-2 d-block">
            Format: kode_barang, nama_barang, merk, harga_satuan, sumber, tahun, deskripsi, stok, kondisi, lokasi, jurusan
        </small>
    </div>

    <!-- Assets Grid -->
    <div class="assets-grid fade-up">
        @forelse($assets as $asset)
            <div class="asset-card">
                <div class="asset-image">
                    @if($asset->photo_url)
                        <img src="{{ $asset->photo_url }}" alt="{{ $asset->name }}">
                    @else
                        <i class="fas fa-box"></i>
                    @endif
                    <div class="asset-stock {{ $asset->stock == 0 ? 'out' : ($asset->stock <= 5 ? 'low' : '') }}">
                        Stok: {{ $asset->stock }}
                    </div>
                </div>
                <div class="asset-details">
                    <div class="asset-name">{{ $asset->name }}</div>
                    <div class="asset-meta">
                        <span><i class="fas fa-tag"></i>{{ $asset->code }}</span>
                        <span><i class="fas fa-map-marker-alt"></i>{{ $asset->lokasi }}</span>
                        <br>
                        <span><i class="fas fa-building"></i>{{ $asset->jurusan }}</span>
                        @if($asset->merk)
                            <span><i class="fas fa-copyright"></i>{{ $asset->merk }}</span>
                        @endif
                    </div>
                    <div class="asset-actions">
                        <button type="button" class="btn-detail" onclick="showAssetDetail({{ $asset->id }})">
                            <i class="fas fa-eye"></i> Detail
                        </button>
                        <div class="action-buttons" style="display: flex; gap: 8px;">
                            <a href="{{ route('admin.assets.edit', $asset->id) }}" class="btn-edit" title="Edit">
                                <i class="fas fa-edit"></i>
                            </a>
                            <button type="button" class="btn-delete" onclick="confirmDelete({{ $asset->id }})" title="Hapus">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        @empty
            <div style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                <i class="fas fa-box-open" style="font-size: 48px; color: #ccc; margin-bottom: 15px;"></i>
                <p style="color: #666; font-size: 16px;">Tidak ada aset yang ditemukan.</p>
            </div>
        @endforelse
    </div>

    <!-- Pagination -->
    <!-- @if($assets->hasPages())
        <div style="display: flex; justify-content: center; margin-top: 30px;">
            {{ $assets->appends(request()->query())->links() }}
        </div>
    @endif -->
</div>

<!-- Detail Modal -->
<div id="asset-detail-modal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title">Detail Aset</h5>
            <span class="close" onclick="closeModal()">&times;</span>
        </div>
        <div class="modal-body" id="modal-body-content">
            <!-- Content will be loaded here -->
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeModal()">Tutup</button>
        </div>
    </div>
</div>

<script>
    // Show asset detail modal
    async function showAssetDetail(assetId) {
        try {
            const response = await fetch(`/admin/assets/${assetId}/detail`);

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Gagal memuat detail aset.');
            }

            const asset = await response.json();

            const modalBody = document.getElementById('modal-body-content');
            modalBody.innerHTML = `
                <div style="display: flex; flex-direction: column; gap: 15px;">
                    <div style="text-align: center;">
                        ${asset.photo_url ?
                            `<img src="${asset.photo_url}" alt="${asset.name}" class="asset-image-large">` :
                            `<i class="fas fa-box" style="font-size: 64px; color: #ccc;"></i>`
                        }
                    </div>
                    <div class="form-group">
                        <label class="form-label">Nama Barang</label>
                        <div class="form-value">${asset.name}</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Kode Barang</label>
                        <div class="form-value">${asset.code}</div>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div class="form-group">
                            <label class="form-label">Stok</label>
                            <div class="form-value">
                                <span class="badge ${asset.stock == 0 ? 'bg-danger' : (asset.stock <= 5 ? 'bg-warning' : 'bg-success')}">
                                    ${asset.stock} unit
                                </span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Kondisi</label>
                            <div class="form-value">${asset.condition || 'Baik'}</div>
                        </div>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div class="form-group">
                            <label class="form-label">Lokasi</label>
                            <div class="form-value">${asset.lokasi}</div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Jurusan</label>
                            <div class="form-value">${asset.jurusan}</div>
                        </div>
                    </div>
                    ${asset.merk ? `
                        <div class="form-group">
                            <label class="form-label">Merk</label>
                            <div class="form-value">${asset.merk}</div>
                        </div>
                    ` : ''}
                    ${asset.sumber ? `
                        <div class="form-group">
                            <label class="form-label">Sumber</label>
                            <div class="form-value">${asset.sumber}</div>
                        </div>
                    ` : ''}
                    ${asset.tahun ? `
                        <div class="form-group">
                            <label class="form-label">Tahun</label>
                            <div class="form-value">${asset.tahun}</div>
                        </div>
                    ` : ''}
                    ${asset.deskripsi ? `
                        <div class="form-group">
                            <label class="form-label">Deskripsi</label>
                            <div class="form-value">${asset.deskripsi}</div>
                        </div>
                    ` : ''}
                </div>
            `;

            document.getElementById('asset-detail-modal').style.display = 'block';
        } catch (error) {
            console.error('Error loading asset detail:', error);
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: error.message || 'Gagal memuat detail aset', // Display specific error message
                showConfirmButton: false,
                timer: 2000
            });
        }
    }

    // Close modal
    function closeModal() {
        document.getElementById('asset-detail-modal').style.display = 'none';
    }

    // Close modal when clicking outside
    window.onclick = function(event) {
        if (event.target == document.getElementById('asset-detail-modal')) {
            closeModal();
        }
    }

    // Confirm delete
    function confirmDelete(assetId) {
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
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = `/admin/assets/${assetId}`;
                form.innerHTML = `
                    @csrf
                    @method('DELETE')
                `;
                document.body.appendChild(form);
                form.submit();
            }
        });
    }

    // Show/hide import form
    document.addEventListener('DOMContentLoaded', function() {
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