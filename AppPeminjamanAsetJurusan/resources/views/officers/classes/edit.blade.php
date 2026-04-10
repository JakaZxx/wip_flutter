@extends('layouts.app')

@section('title', 'Edit Kelas')

@section('content')
<style>
    /* Animasi slide up */
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    /* Container utama */
    .edit-container {
        max-width: 650px;
        margin: auto;
        background: #ffffff;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        padding: 28px 30px;

        /* Animasi */
        animation: slideUp 0.6s ease-out;
    }

    /* Judul */
    .edit-container h2 {
        font-weight: 600;
        font-size: 1.5rem;
        color: #2b3e50;
        margin-bottom: 25px;
        border-bottom: 2px solid #e9ecef;
        padding-bottom: 10px;
    }

    /* Label */
    .edit-container label {
        font-weight: 500;
        color: #495057;
        margin-bottom: 8px;
        display: block;
    }

    /* Input & Select & Textarea */
    .edit-container input,
    .edit-container select,
    .edit-container textarea {
        border-radius: 6px;
        border: 1px solid #ced4da;
        padding: 10px 12px;
        font-size: 14px;
        transition: 0.2s ease;
        width: 100%;
        margin-bottom: 20px;
    }

    .edit-container input:focus,
    .edit-container select:focus,
    .edit-container textarea:focus {
        border-color: #0d6efd;
        box-shadow: 0 0 0 3px rgba(13,110,253,0.15);
    }

    /* Tombol */
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
        text-decoration: none;
    }
    .btn-back:hover {
        background-color: #5a6268;
    }

    /* Animasi untuk import siswa */
    #import-students-form {
        display: none;
        background: #f8f9fa;
        padding: 20px;
        border-radius: 8px;
        border: 1px solid #dee2e6;
    }
    #import-students-form.show {
        display: block;
        animation: slideUp 0.5s ease-out;
    }

    /* Responsive mobile */
    @media (max-width: 576px) {
        .edit-container {
            padding: 20px;
        }
        .edit-container h2 {
            font-size: 1.3rem;
        }
        .btn-save, .btn-back {
            width: 100%;
            margin-bottom: 10px;
        }
    }
</style>

<div class="container-fluid">
    <div class="edit-container">
        <h2>Edit Data Kelas</h2>

        @if($errors->any())
            <div class="alert alert-danger">
                <ul class="mb-0">
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('officers.classes.update', $schoolClass) }}" method="POST">
            @csrf
            @method('PUT')
            
            <div class="mb-3">
                <label for="name">Nama Kelas <span class="text-danger">*</span></label>
                <input type="text" 
                    class="@error('name') is-invalid @enderror" 
                    id="name" 
                    name="name" 
                    placeholder="contoh: XII RPL 3"
                    value="{{ old('name', $schoolClass->name) }}" 
                    required>
                @error('name')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="level">Tingkat Kelas <span class="text-danger">*</span></label>
                <select id="level" name="level" class="@error('level') is-invalid @enderror" required>
                    <option value="">Pilih Tingkat</option>
                    <option value="X" {{ old('level', $schoolClass->level) == 'X' ? 'selected' : '' }}>X</option>
                    <option value="XI" {{ old('level', $schoolClass->level) == 'XI' ? 'selected' : '' }}>XI</option>
                    <option value="XII" {{ old('level', $schoolClass->level) == 'XII' ? 'selected' : '' }}>XII</option>
                </select>
                @error('level')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="program_study">Program Studi <span class="text-danger">*</span></label>
                <select id="program_study" name="program_study" class="@error('program_study') is-invalid @enderror" required>
                    <option value="">-- Pilih Program Studi --</option>
                    <option value="Rekayasa Perangkat Lunak" {{ old('program_study', $schoolClass->program_study) == 'Rekayasa Perangkat Lunak' ? 'selected' : '' }}>Rekayasa Perangkat Lunak</option>
                    <option value="Teknik Instalasi Tenaga Listrik" {{ old('program_study', $schoolClass->program_study) == 'Teknik Instalasi Tenaga Listrik' ? 'selected' : '' }}>Teknik Instalasi Tenaga Listrik</option>
                    <option value="Desain Komunikasi Visual" {{ old('program_study', $schoolClass->program_study) == 'Desain Komunikasi Visual' ? 'selected' : '' }}>Desain Komunikasi Visual</option>
                    <option value="Teknik Audio Video" {{ old('program_study', $schoolClass->program_study) == 'Teknik Audio Video' ? 'selected' : '' }}>Teknik Audio Video</option>
                    <option value="Teknik Otomasi Industri" {{ old('program_study', $schoolClass->program_study) == 'Teknik Otomasi Industri' ? 'selected' : '' }}>Teknik Otomasi Industri</option>
                    <option value="Teknik Komputer Jaringan" {{ old('program_study', $schoolClass->program_study) == 'Teknik Komputer Jaringan' ? 'selected' : '' }}>Teknik Komputer Jaringan</option>
                </select>
                @error('program_study')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="capacity">Kapasitas Siswa <span class="text-danger">*</span></label>
                <input type="number" class="@error('capacity') is-invalid @enderror" 
                    id="capacity" name="capacity" 
                    value="{{ old('capacity', $schoolClass->capacity) }}" min="1" max="50" required>
                @error('capacity')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="description">Deskripsi</label>
                <textarea class="@error('description') is-invalid @enderror" 
                        id="description" 
                        name="description" 
                        rows="3" 
                        placeholder="Opsional">{{ old('description', $schoolClass->description) }}</textarea>
                @error('description')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn-save">
                    <i class="bx bx-save"></i> Update
                </button>
                <a href="{{ route('officers.classes.index') }}" class="btn-back"> Kembali</a>
            </div>
        </form>

        <!-- Import Students Section -->
        <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid #e9ecef;">
            <h3 style="font-size: 1.2rem; margin-bottom: 15px; color: #2b3e50;">Import Data Siswa</h3>
            <p style="color: #6c757d; font-size: 14px; margin-bottom: 15px;">
                Import data siswa untuk kelas ini. Setiap siswa akan otomatis dibuatkan akun dengan password default "smkn4bdg".
            </p>

            <!-- Import Students Button -->
            <button type="button" class="btn btn-success mb-3" onclick="showImportForm()">
                <i class="fas fa-upload"></i> Import Siswa
            </button>

            <!-- Import Students Form -->
            <div id="import-students-form">
                <h5 style="margin-bottom: 15px; color: #333;">Import Data Siswa</h5>
                <form action="{{ route('officers.import.students', $schoolClass) }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    <div class="mb-3">
                        <label for="students_file" class="form-label">Pilih File Excel</label>
                        <input type="file" class="form-control" id="students_file" name="file" accept=".xlsx,.csv" required>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-upload"></i> Import
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="hideImportForm()">
                            <i class="fas fa-times"></i> Batal
                        </button>
                    </div>
                </form>
                <small class="text-muted mt-2 d-block">Format: nama, email</small>
            </div>
        </div>
    </div>
</div>

<script>
    function showImportForm() {
        document.getElementById('import-students-form').classList.add('show');
    }
    function hideImportForm() {
        document.getElementById('import-students-form').classList.remove('show');
    }
</script>
@endsection
