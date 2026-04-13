@extends('layouts.app')

@section('title', 'Tambah Kelas')

@section('content')
<link rel="stylesheet" href="{{ asset('css/admin/classes/create.css') }}">

<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title mb-0">Tambah Data Kelas</h3>
                </div>
                <div class="card-body">
                    @if($errors->any())
                        <div class="alert alert-danger">
                            <ul class="mb-0">
                                @foreach($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif

                    <form action="{{ route('admin.classes.store') }}" method="POST">
                        @csrf
                        
                        <div class="mb-3">
                        <label for="name" class="form-label">Nama Kelas <span class="text-danger">*</span></label>
                        <input type="text" 
                            class="form-control @error('name') is-invalid @enderror" 
                            id="name" 
                            name="name" 
                            placeholder="contoh: XII RPL 3"
                            value="{{ old('name') }}" 
                            required>
                        @error('name')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                        <div class="mb-3">
                            <label for="level" class="form-label">Tingkat Kelas <span class="text-danger">*</span></label>
                            <select class="form-select @error('level') is-invalid @enderror" id="level" name="level" required>
                                <option value="">Pilih Tingkat</option>
                                <option value="X" {{ old('level') == 'X' ? 'selected' : '' }}>X</option>
                                <option value="XI" {{ old('level') == 'XI' ? 'selected' : '' }}>XI</option>
                                <option value="XII" {{ old('level') == 'XII' ? 'selected' : '' }}>XII</option>
                            </select>
                            @error('level')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                       <div class="mb-3">
                        <label for="program_study" class="form-label">Program Studi <span class="text-danger">*</span></label>
                        <select id="program_study" name="program_study" class="form-control @error('program_study') is-invalid @enderror" required>
                            <option value="">-- Pilih Program Studi --</option>
                            <option value="Rekayasa Perangkat Lunak" {{ old('program_study') == 'Rekayasa Perangkat Lunak' ? 'selected' : '' }}>Rekayasa Perangkat Lunak</option>
                            <option value="Teknik Instalasi Tenaga Listrik" {{ old('program_study') == 'Teknik Instalasi Tenaga Listrik' ? 'selected' : '' }}>Teknik Instalasi Tenaga Listrik</option>
                            <option value="Desain Komunikasi Visual" {{ old('program_study') == 'Desain Komunikasi Visual' ? 'selected' : '' }}>Desain Komunikasi Visual</option>
                            <option value="Teknik Audio Video" {{ old('program_study') == 'Teknik Audio Video' ? 'selected' : '' }}>Teknik Audio Video</option>
                            <option value="Teknik Otomasi Industri" {{ old('program_study') == 'Teknik Otomasi Industri' ? 'selected' : '' }}>Teknik Otomasi Industri</option>
                            <option value="Teknik Komputer Jaringan" {{ old('program_study') == 'Teknik Komputer Jaringan' ? 'selected' : '' }}>Teknik Komputer Jaringan</option>
                        </select>
                        @error('program_study')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                        <div class="mb-3">
                            <label for="capacity" class="form-label">Kapasitas Siswa <span class="text-danger">*</span></label>
                            <input type="number" class="form-control @error('capacity') is-invalid @enderror" 
                                   id="capacity" name="capacity" value="{{ old('capacity', 30) }}" min="1" max="50" required>
                            @error('capacity')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label for="description" class="form-label">Deskripsi</label>
                            <textarea class="form-control @error('description') is-invalid @enderror" 
                                    id="description" 
                                    name="description" 
                                    rows="3" 
                                    placeholder="Opsional">{{ old('description') }}</textarea>
                            @error('description')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bx bx-save"></i> Simpan
                            </button>
                            <a href="{{ route('admin.classes.index') }}" class="btn btn-secondary"> Kembali</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
