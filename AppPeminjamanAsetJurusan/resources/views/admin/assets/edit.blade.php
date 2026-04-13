@extends('layouts.app')

@section('title', 'Edit Barang')

@section('content')
<style>
    /* Container utama */
.edit-container {
    max-width: 650px;
    margin: auto;
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 6px 20px rgba(0,0,0,0.08);
    padding: 28px 30px;
    animation: fadeIn 0.5s ease-in-out;
}

/* Animasi muncul */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(15px); }
    to { opacity: 1; transform: translateY(0); }
}

/* Judul */
.edit-container h2 {
    font-weight: 700;
    font-size: 1.7rem;
    color: #2b3e50;
    margin-bottom: 25px;
    border-bottom: 2px solid #e9ecef;
    padding-bottom: 12px;
    text-align: center;
    letter-spacing: 0.5px;
}

/* Label */
.edit-container label {
    font-weight: 600;
    color: #495057;
    margin-bottom: 6px;
    display: block;
    font-size: 0.95rem;
}

/* Input & Select */
.edit-container input,
.edit-container select {
    border-radius: 8px;
    border: 1px solid #ced4da;
    padding: 11px 14px;
    font-size: 14px;
    transition: all 0.25s ease;
    width: 100%;
    margin-bottom: 20px;
    background: #f9f9f9;
}

.edit-container input:focus,
.edit-container select:focus {
    border-color: #0d6efd;
    box-shadow: 0 0 8px rgba(13,110,253,0.25);
    background: #fff;
}

/* Select khusus */
.edit-container select {
    cursor: pointer;
    appearance: none;
    background-image: url("data:image/svg+xml;utf8,<svg fill='gray' height='18' viewBox='0 0 24 24' width='18' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/></svg>");
    background-repeat: no-repeat;
    background-position: right 14px center;
    background-size: 14px;
    padding-right: 40px;
}

/* Tombol Save */
.btn-save {
    background: linear-gradient(135deg, #0d6efd, #0a58ca);
    border: none;
    padding: 12px 24px;
    border-radius: 8px;
    font-weight: 600;
    color: #fff;
    font-size: 0.95rem;
    transition: all 0.3s ease;
    box-shadow: 0 4px 10px rgba(13,110,253,0.25);
}
.btn-save:hover {
    background: linear-gradient(135deg, #0a58ca, #084298);
    transform: translateY(-2px);
}

/* Tombol Back */
.btn-back {
    background: linear-gradient(135deg, #6c757d, #495057);
    border: none;
    padding: 12px 24px;
    border-radius: 8px;
    font-weight: 600;
    color: #fff;
    font-size: 0.95rem;
    transition: all 0.3s ease;
    box-shadow: 0 4px 10px rgba(73,80,87,0.25);
}
.btn-back:hover {
    background: linear-gradient(135deg, #495057, #343a40);
    transform: translateY(-2px);
}

/* Responsif */
@media (max-width: 576px) {
    .edit-container {
        padding: 20px;
    }
    .edit-container h2 {
        font-size: 1.4rem;
    }
    .btn-save, .btn-back {
        width: 100%;
        margin-bottom: 12px;
    }
}

</style>

<div class="container mt-4">
    <div class="edit-container">
        <h2>Edit Data Barang</h2>
        @if ($errors->any())
            <div class="alert alert-danger">
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif
        <form action="{{ route('admin.assets.update', $commodity->id) }}" method="POST" enctype="multipart/form-data">
            @csrf
            @method('PUT')

            <label for="name">Nama Barang</label>
            <input type="text" id="name" name="name" value="{{ old('name', $commodity->name) }}" required>

            <label for="code">Kode Barang</label>
            <input type="number" id="code" name="code" value="{{ old('code', $commodity->code) }}" required>

            <label for="stock">Jumlah Stok</label>
            <input type="number" id="stock" name="stock" value="{{ old('stock', $commodity->stock) }}" required>

            <label for="lokasi">Lokasi Barang</label>
            <input type="text" id="lokasi" name="lokasi" value="{{ old('lokasi', $commodity->lokasi) }}" required>

            <label for="jurusan">Jurusan Barang</label>
            <select id="jurusan" name="jurusan" required>
                <option value="" disabled>Pilih Jurusan</option>
                <option value="Teknik Komputer Jaringan" {{ old('jurusan', ucwords($commodity->jurusan)) == 'Teknik Komputer Jaringan' ? 'selected' : '' }}>Teknik Komputer Jaringan</option>
                <option value="Rekayasa Perangkat Lunak" {{ old('jurusan', ucwords($commodity->jurusan)) == 'Rekayasa Perangkat Lunak' ? 'selected' : '' }}>Rekayasa Perangkat Lunak</option>
                <option value="Desain Komunikasi Visual" {{ old('jurusan', ucwords($commodity->jurusan)) == 'Desain Komunikasi Visual' ? 'selected' : '' }}>Desain Komunikasi Visual</option>
                <option value="Teknik Otomasi Industri" {{ old('jurusan', ucwords($commodity->jurusan)) == 'Teknik Otomasi Industri' ? 'selected' : '' }}>Teknik Otomasi Industri</option>
                <option value="Teknik Instalasi Tenaga Listrik" {{ old('jurusan', ucwords($commodity->jurusan)) == 'Teknik Instalasi Tenaga Listrik' ? 'selected' : '' }}>Teknik Instalasi Tenaga Listrik</option>
                <option value="Teknik Audio Video" {{ old('jurusan', ucwords($commodity->jurusan)) == 'Teknik Audio Video' ? 'selected' : '' }}>Teknik Audio Video</option>
            </select>

            <label for="merk">Merk</label>
            <input type="text" id="merk" name="merk" value="{{ old('merk', $commodity->merk) }}">

            <label for="harga_satuan">Harga Satuan</label>
            <input type="number" id="harga_satuan" name="harga_satuan" value="{{ old('harga_satuan', $commodity->harga_satuan) }}">

            <label for="sumber">Sumber</label>
            <input type="text" id="sumber" name="sumber" value="{{ old('sumber', $commodity->sumber) }}">

            <label for="tahun">Tahun</label>
            <input type="number" id="tahun" name="tahun" value="{{ old('tahun', $commodity->tahun) }}">

            <label for="deskripsi">Deskripsi</label>
            <textarea id="deskripsi" name="deskripsi" rows="3">{{ old('deskripsi', $commodity->deskripsi) }}</textarea>

            <label for="photo">Foto Barang</label>
            @if($commodity->photo)
                <div style="margin-bottom: 10px;">
                    <img src="{{ $commodity->photo }}" alt="{{ $commodity->name }}" width="100" style="border-radius: 5px;">
                </div>
            @endif
            <input type="file" id="photo" name="photo">
            <small>Kosongkan jika tidak ingin mengubah foto.</small>

            <div class="d-flex justify-content-between flex-wrap">
                <button type="submit" class="btn-save">Update</button>
                <a href="{{ route('admin.assets.index') }}" class="btn-back">Kembali</a>
            </div>
        </form>
    </div>
</div>
@endsection