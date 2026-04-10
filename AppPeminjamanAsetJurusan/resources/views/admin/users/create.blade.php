@extends('layouts.app')

@section('title', 'Tambah User')

@section('content')
<link rel="stylesheet" href="{{ asset('css/admin/users/create.css') }}">
<div class="container">
    <h1>Tambah User</h1>
    
    @if($errors->any())
        <div class="alert alert-danger" style="background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
            <ul style="margin: 0; padding-left: 20px;">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('users.store') }}" method="POST">
        @csrf
        <div class="form-group">
            <label for="name">Nama</label>
            <input type="text" name="name" class="form-control" value="{{ old('name') }}" required>
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" name="email" class="form-control" value="{{ old('email') }}" required>
        </div>

        <div class="form-group">
            <label for="role">Role</label>
            <select name="role" id="role" class="form-control" required>
                <option value="">-- Pilih Role --</option>
                <option value="admin" {{ old('role') == 'admin' ? 'selected' : '' }}>Admin</option>
                <option value="students" {{ old('role') == 'students' ? 'selected' : '' }}>Students</option>
                <option value="officers" {{ old('role') == 'officers' ? 'selected' : '' }}>Officers</option>
            </select>
        </div>

        <div class="form-group" id="jurusan_field" style="display: none;">
            <label for="jurusan">Jurusan</label>
            <select name="jurusan" id="jurusan" class="form-control">
                <option value="">-- Pilih Jurusan --</option>
                <option value="Rekayasa Perangkat Lunak" {{ old('jurusan') == 'Rekayasa Perangkat Lunak' ? 'selected' : '' }}>Rekayasa Perangkat Lunak</option>
                <option value="Desain Komunikasi Visual" {{ old('jurusan') == 'Desain Komunikasi Visual' ? 'selected' : '' }}>Desain Komunikasi Visual</option>
                <option value="Teknik Audio Video" {{ old('jurusan') == 'Teknik Audio Video' ? 'selected' : '' }}>Teknik Audio Video</option>
                <option value="Teknik Komputer Jaringan" {{ old('jurusan') == 'Teknik Komputer Jaringan' ? 'selected' : '' }}>Teknik Komputer Jaringan</option>
                <option value="Teknik Instalasi Tenaga Listrik" {{ old('jurusan') == 'Teknik Instalasi Tenaga Listrik' ? 'selected' : '' }}>Teknik Instalasi Tenaga Listrik</option>
                <option value="Teknik Otomasi Industri" {{ old('jurusan') == 'Teknik Otomasi Industri' ? 'selected' : '' }}>Teknik Otomasi Industri</option>
            </select>
        </div>

        <!-- Field School Class (Hidden Default) -->
        <div class="form-group" id="school_class_field" style="display: none;">
            <label for="school_class_id">Kelas</label>
            <select name="school_class_id" id="school_class_id" class="form-control">
                <option value="">-- Pilih Kelas --</option>
                @foreach($schoolClasses as $class)
                    <option value="{{ $class->id }}" {{ old('school_class_id') == $class->id ? 'selected' : '' }}>{{ $class->name }}</option>
                @endforeach
            </select>
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" name="password" class="form-control" required minlength="8">
        </div>

        <div class="form-group">
            <label for="password_confirmation">Konfirmasi Password</label>
            <input type="password" name="password_confirmation" class="form-control" required minlength="8">
        </div>
        
        <div class="button-group">
            <button type="submit" class="btn btn-primary">Simpan</button>
            <a href="{{ route('users.index') }}" class="btn btn-secondary">Kembali</a>
        </div>
    </form>
</div>

    <script>
        document.getElementById('role').addEventListener('change', function () {
            let schoolField = document.getElementById('school_class_field');
            let schoolClassSelect = document.getElementById('school_class_id');
            let jurusanField = document.getElementById('jurusan_field');
            let jurusanSelect = document.getElementById('jurusan');

            if (this.value === 'students') {
                schoolField.style.display = 'block';
                schoolClassSelect.setAttribute('required', 'required'); // wajib kalau students
                jurusanField.style.display = 'none';
                jurusanSelect.removeAttribute('required');
                jurusanSelect.value = "";
            } else if (this.value === 'officers') {
                jurusanField.style.display = 'block';
                jurusanSelect.setAttribute('required', 'required'); // wajib kalau officers
                schoolField.style.display = 'none';
                schoolClassSelect.removeAttribute('required');
                schoolClassSelect.value = "";
            } else {
                schoolField.style.display = 'none';
                schoolClassSelect.removeAttribute('required'); // hilangin wajib
                schoolClassSelect.value = ""; // reset isi
                jurusanField.style.display = 'none';
                jurusanSelect.removeAttribute('required');
                jurusanSelect.value = "";
            }
        });

        // Check on page load if role is already selected
        document.addEventListener('DOMContentLoaded', function () {
            let roleSelect = document.getElementById('role');
            let schoolField = document.getElementById('school_class_field');
            let schoolClassSelect = document.getElementById('school_class_id');
            let jurusanField = document.getElementById('jurusan_field');
            let jurusanSelect = document.getElementById('jurusan');

            if (roleSelect.value === 'students') {
                schoolField.style.display = 'block';
                schoolClassSelect.setAttribute('required', 'required');
                jurusanField.style.display = 'none';
                jurusanSelect.removeAttribute('required');
                jurusanSelect.value = "";
            } else if (roleSelect.value === 'officers') {
                jurusanField.style.display = 'block';
                jurusanSelect.setAttribute('required', 'required');
                schoolField.style.display = 'none';
                schoolClassSelect.removeAttribute('required');
                schoolClassSelect.value = "";
            } else {
                schoolField.style.display = 'none';
                schoolClassSelect.removeAttribute('required');
                schoolClassSelect.value = "";
                jurusanField.style.display = 'none';
                jurusanSelect.removeAttribute('required');
                jurusanSelect.value = "";
            }
        });

        // Handle form submission to remove school_class_id or jurusan if not applicable
        document.querySelector('form').addEventListener('submit', function(e) {
            let roleSelect = document.getElementById('role');
            let schoolClassSelect = document.getElementById('school_class_id');
            let jurusanSelect = document.getElementById('jurusan');
            
            if (roleSelect.value !== 'students') {
                schoolClassSelect.removeAttribute('name');
            }
            if (roleSelect.value !== 'officers') {
                jurusanSelect.removeAttribute('name');
            }
        });
    </script>
@endsection
