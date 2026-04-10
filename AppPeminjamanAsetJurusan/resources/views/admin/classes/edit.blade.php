@extends('layouts.app')

@section('title', 'Edit Kelas')

@section('content')
<link rel="stylesheet" href="{{ asset('css/admin/classes/edit.css') }}">

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

        <form action="{{ route('admin.classes.update', $schoolClass) }}" method="POST">
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
                <a href="{{ route('admin.classes.index') }}" class="btn-back"> Kembali</a>
            </div>
        </form>

        <!-- Import Students Section -->
        <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid #e9ecef;">
            <h3 style="font-size: 1.2rem; margin-bottom: 15px; color: #2b3e50;">Import Data Siswa</h3>
            <p style="color: #6c757d; font-size: 14px; margin-bottom: 15px;">
                Import data siswa untuk kelas ini. Setiap siswa akan otomatis dibuatkan akun dengan password default "smkn4bdg".
            </p>

            <!-- Import Students Button -->
            <button type="button" class="btn btn-success mb-3" onclick="document.getElementById('import-students-form').style.display='block'">
                <i class="fas fa-upload"></i> Import Siswa
            </button>

            <!-- Import Students Form (Hidden by default) -->
            <div id="import-students-form" style="display: none; background: #f8f9fa; padding: 20px; border-radius: 8px; border: 1px solid #dee2e6;">
                <h5 style="margin-bottom: 15px; color: #333;">Import Data Siswa</h5>
                <form action="{{ route('admin.import.students', $schoolClass) }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    <div class="mb-3">
                        <label for="students_file" class="form-label">Pilih File Excel</label>
                        <input type="file" class="form-control" id="students_file" name="file" accept=".xlsx,.csv" required>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-upload"></i> Import
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="document.getElementById('import-students-form').style.display='none'">
                            <i class="fas fa-times"></i> Batal
                        </button>
                    </div>
                </form>
                <small class="text-muted mt-2 d-block">Format: nama, email</small>
            </div>
        </div>
    </div>
</div>
@endsection
