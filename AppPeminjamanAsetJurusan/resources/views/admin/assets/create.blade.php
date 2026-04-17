@extends('layouts.app')

@section('title', 'Tambah Barang')

@section('content')
<style>
/* ====== Container ====== */
.container {
    max-width: 600px;
    margin: 40px auto;
    padding: 25px;
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* ====== Title ====== */
.container h2 {
    text-align: center;
    font-size: 24px;
    font-weight: 600;
    margin-bottom: 25px;
    color: #333;
}

/* ====== Form Elements ====== */
.form-label {
    font-weight: 500;
    margin-bottom: 6px;
    display: block;
    color: #444;
}

.form-control {
    width: 100%;
    padding: 10px 14px;
    border: 1px solid #ccc;
    border-radius: 8px;
    font-size: 15px;
    outline: none;
    transition: all 0.2s ease-in-out;
    background-color: #fafafa;
}

.form-control:focus {
    border-color: #007bff;
    background-color: #fff;
    box-shadow: 0 0 0 3px rgba(0,123,255,0.15);
}

.mb-3 {
    margin-bottom: 20px;
}

/* ====== Buttons ====== */
.btn-primary {
    padding: 10px 20px;
    background: linear-gradient(90deg, #007bff, #0056b3);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    transition: 0.3s;
}

.btn-primary:hover {
    background: linear-gradient(90deg, #0056b3, #004094);
}

.btn-secondary {
    padding: 10px 20px;
    background-color: #6c757d;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 500;
    text-decoration: none;
    transition: 0.3s;
    margin-left: 8px;
}

.btn-secondary:hover {
    background-color: #5a6268;
}

/* ====== Responsive ====== */
@media (max-width: 576px) {
    .container {
        padding: 15px;
    }
    .container h2 {
        font-size: 20px;
    }
    .btn-primary, .btn-secondary {
        font-size: 14px;
        padding: 8px 16px;
        width: 100%;
        margin-top: 10px;
    }
}
</style>

<div class="container mt-5">
    <h2>Tambah Data Barang</h2>
    @if ($errors->any())
        <div class="alert alert-danger">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif
    <form action="{{ route('admin.assets.store') }}" method="POST" enctype="multipart/form-data">
        @csrf
        <div class="mb-3">
            <label for="name" class="form-label">Nama Barang</label>
            <input type="text" class="form-control" id="name" name="name" required>
        </div>
        <div class="mb-3">
            <label for="code" class="form-label">Kode Barang</label>
            <input type="number" class="form-control" id="code" name="code" required>
        </div>
        <div class="mb-3">
            <label for="stock" class="form-label">Jumlah Stok</label>
            <input type="number" class="form-control" id="stock" name="stock" required>
        </div>
        <div class="mb-3">
            <label for="lokasi" class="form-label">Lokasi Barang</label>
            <input type="text" class="form-control" id="lokasi" name="lokasi" required>
        </div>
        <div class="mb-3">
            <label for="jurusan" class="form-label">Jurusan Barang</label>
            <select class="form-control" id="jurusan" name="jurusan" required>
                <option value="" disabled {{ old('jurusan') ? '' : 'selected' }}>Pilih Jurusan</option>
                <option value="Teknik Komputer Jaringan" {{ old('jurusan') == 'Teknik Komputer Jaringan' ? 'selected' : '' }}>Teknik Audio Video</option>
                <option value="Rekayasa Perangkat Lunak" {{ old('jurusan') == 'Rekayasa Perangkat Lunak' ? 'selected' : '' }}>Rekayasa Perangkat Lunak</option>
                <option value="Desain Komunikasi Visual" {{ old('jurusan') == 'Desain Komunikasi Visual' ? 'selected' : '' }}>Desain Komunikasi Visual</option>
                <option value="Teknik Otomasi Industri" {{ old('jurusan') == 'Teknik Otomasi Industri' ? 'selected' : '' }}>Teknik Otomasi Industri</option>
                <option value="Teknik Instalasi Tenaga Listrik" {{ old('jurusan') == 'Teknik Instalasi Tenaga Listrik' ? 'selected' : '' }}>Teknik Instalasi Tenaga Listrik</option>
                <option value="Teknik Audio Video" {{ old('jurusan') == 'Teknik Audio Video' ? 'selected' : '' }}>Teknik Audio Video</option>
            </select>
        </div>
        <div class="mb-3">
            <label for="merk" class="form-label">Merk</label>
            <input type="text" class="form-control" id="merk" name="merk" value="{{ old('merk') }}">
        </div>
        <div class="mb-3">
            <label for="harga_satuan" class="form-label">Harga Satuan</label>
            <input type="number" class="form-control" id="harga_satuan" name="harga_satuan" value="{{ old('harga_satuan') }}">
        </div>
        <div class="mb-3">
            <label for="sumber" class="form-label">Sumber</label>
            <input type="text" class="form-control" id="sumber" name="sumber" value="{{ old('sumber') }}">
        </div>
        <div class="mb-3">
            <label for="tahun" class="form-label">Tahun</label>
            <input type="number" class="form-control" id="tahun" name="tahun" value="{{ old('tahun') }}">
        </div>
        <div class="mb-3">
            <label for="deskripsi" class="form-label">Deskripsi</label>
            <textarea class="form-control" id="deskripsi" name="deskripsi" rows="3">{{ old('deskripsi') }}</textarea>
        </div>
        <div class="mb-3">
            <label for="photo" class="form-label">Foto Barang</label>
            <input type="file" class="form-control" id="photo" name="photo">
        </div>
        <button type="submit" class="btn btn-primary">Simpan</button>
        <a href="{{ route('admin.assets.index') }}" class="btn btn-secondary">Kembali</a>
    </form>
</div>

<script>
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