@extends('layouts.app')

@section('title', 'Edit Barang')

@section('content')
<style>
    .edit-container {
        max-width: 650px;
        margin: auto;
        background: #ffffff;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        padding: 28px 30px;
    }

    .edit-container h2 {
        font-weight: 600;
        font-size: 1.5rem;
        color: #2b3e50;
        margin-bottom: 25px;
        border-bottom: 2px solid #e9ecef;
        padding-bottom: 10px;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .edit-container label {
        font-weight: 500;
        color: #495057;
        margin-bottom: 8px;
        display: block;
    }

    .edit-container input {
        border-radius: 6px;
        border: 1px solid #ced4da;
        padding: 10px 12px;
        font-size: 14px;
        transition: 0.2s ease;
        width: 100%;
    }

    .edit-container input:focus {
        border-color: #0d6efd;
        box-shadow: 0 0 0 3px rgba(13,110,253,0.15);
    }

    .btn-save {
        background-color: #0d6efd;
        border: none;
        padding: 10px 20px;
        border-radius: 6px;
        font-weight: 500;
        color: #fff;
        transition: background 0.3s ease;
    }

    .btn-save:hover {
        background-color: #0b5ed7;
    }

    .btn-back {
        background-color: #6c757d;
        border: none;
        padding: 10px 20px;
        border-radius: 6px;
        font-weight: 500;
        color: white;
        transition: background 0.3s ease;
    }

    .btn-back:hover {
        background-color: #5a6268;
    }

    .button-group {
        display: flex;
        justify-content: space-between;
        gap: 10px;
        flex-wrap: wrap;
    }

    @media (max-width: 576px) {
        .edit-container {
            padding: 20px;
        }

        .edit-container h2 {
            font-size: 1.3rem;
        }

        .btn-save,
        .btn-back {
            width: 100%;
        }

        .button-group {
            flex-direction: column;
        }
    }

    .edit-container select#jurusan {
        display: block !important;
        width: 100% !important;
        padding: 10px 14px !important;
        font-size: 14px !important;
        font-weight: 400 !important;
        line-height: 1.5 !important;
        color: #495057 !important;
        background-color: #fff !important;
        border: 1px solid #ced4da !important;
        border-radius: 6px !important;
        transition: border-color .15s ease-in-out, box-shadow .15s ease-in-out !important;
        appearance: none !important;
        background-image: url("data:image/svg+xml;utf8,<svg fill='%23495057' height='20' viewBox='0 0 24 24' width='20' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/></svg>") !important;
        background-repeat: no-repeat !important;
        background-position: right 12px center !important;
        background-size: 16px 16px !important;
        cursor: pointer !important;
    }

    .edit-container select#jurusan:focus {
        border-color: #0d6efd !important;
        box-shadow: 0 0 0 3px rgba(13,110,253,.15) !important;
        outline: none !important;
    }

    .edit-container select#jurusan option {
        padding: 8px 12px !important;
    }
    .button-group {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
    margin-top: 25px; /* 🔹 Tambahin jarak lebih lega */
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
        <form action="{{ route('officers.assets.update', $commodity->id) }}" method="POST" enctype="multipart/form-data" style="margin-bottom: 0;">
            @csrf
            @method('PUT')

            <div class="form-group">
                <label for="name">Nama Barang</label>
                <input type="text" id="name" name="name" value="{{ $commodity->name }}" required>
            </div>

            <div class="form-group">
                <label for="code">Kode Barang</label>
                <input type="number" id="code" name="code" value="{{ $commodity->code }}" required>
            </div>

            <div class="form-group">
                <label for="stock">Jumlah Stok</label>
                <input type="number" id="stock" name="stock" value="{{ $commodity->stock }}" required>
            </div>

            <div class="form-group">
                <label for="lokasi">Lokasi Barang</label>
                <input type="text" id="lokasi" name="lokasi" value="{{ $commodity->lokasi }}" required>
            </div>



            <div class="form-group">
                <label for="merk">Merk</label>
                <input type="text" id="merk" name="merk" value="{{ $commodity->merk }}">
            </div>

            <div class="form-group">
                <label for="harga_satuan">Harga Satuan</label>
                <input type="number" id="harga_satuan" name="harga_satuan" value="{{ $commodity->harga_satuan }}">
            </div>

            <div class="form-group">
                <label for="sumber">Sumber</label>
                <input type="text" id="sumber" name="sumber" value="{{ $commodity->sumber }}">
            </div>

            <div class="form-group">
                <label for="tahun">Tahun</label>
                <input type="number" id="tahun" name="tahun" value="{{ $commodity->tahun }}">
            </div>

            <div class="form-group">
                <label for="deskripsi">Deskripsi</label>
                <textarea id="deskripsi" name="deskripsi" rows="3">{{ $commodity->deskripsi }}</textarea>
            </div>

            <div class="form-group">
                <label for="photo">Foto Barang</label>
                @if($commodity->photo_url)
                    <div style="margin-bottom: 10px;">
                        <img src="{{ $commodity->photo_url }}" alt="{{ $commodity->name }}" width="100" style="border-radius: 5px;">
                    </div>
                @endif
                <input type="file" id="photo" name="photo">
                <small>Kosongkan jika tidak ingin mengubah foto.</small>
            </div>

            <div class="button-group mt-3">
                <button type="submit" class="btn-save">Update</button>
                <a href="{{ route('officers.assets.index') }}" class="btn-back">Kembali</a>
            </div>
        </form>
    </div>
</div>
@endsection
