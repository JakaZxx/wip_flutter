@extends('layouts.app')

@section('title', 'Edit User')

@section('content')
<link rel="stylesheet" href="{{ asset('css/admin/users/edit.css') }}">
<div class="container">
    <h1>Edit User</h1>
    
    @if($errors->any())
        <div class="alert alert-danger" style="background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
            <ul style="margin: 0; padding-left: 20px;">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('users.update', $user->id) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="form-group">
            <label for="name">Nama</label>
            <input type="text" name="name" class="form-control" value="{{ old('name', $user->name) }}" required>
        </div>
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" name="email" class="form-control" value="{{ old('email', $user->email) }}" required>
        </div>
        <div class="form-group">
            <label for="role">Role</label>
            <select name="role" id="role" class="form-control" required>
                <option value="admin" {{ old('role', $user->role) == 'admin' ? 'selected' : '' }}>Admin</option>
                <option value="students" {{ old('role', $user->role) == 'students' ? 'selected' : '' }}>Students</option>
                <option value="officers" {{ old('role', $user->role) == 'officers' ? 'selected' : '' }}>Officers</option>
            </select>
        </div>

        <!-- Field School Class -->
        <div class="form-group" id="school_class_field" style="display: none;">
            <label for="school_class_id">Kelas</label>
            <select name="school_class_id" id="school_class_id" class="form-control">
                <option value="">-- Pilih Kelas --</option>
                @foreach($schoolClasses as $class)
                    <option value="{{ $class->id }}" {{ old('school_class_id', $user->student->school_class_id ?? '') == $class->id ? 'selected' : '' }}>
                        {{ $class->name }}
                    </option>
                @endforeach
            </select>
        </div>

        <div class="button-group">
            <button type="submit" class="btn btn-primary">Update</button>
            <a href="{{ route('users.index') }}" class="btn btn-secondary">Kembali</a>
        </div>
    </form>
</div>

<script>
    document.getElementById('role').addEventListener('change', function () {
        let schoolField = document.getElementById('school_class_field');
        let schoolClassSelect = document.getElementById('school_class_id');

        if (this.value === 'students') {
            schoolField.style.display = 'block';
            schoolClassSelect.setAttribute('required', 'required');
        } else {
            schoolField.style.display = 'none';
            schoolClassSelect.removeAttribute('required');
            schoolClassSelect.value = "";
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        let roleSelect = document.getElementById('role');
        let schoolField = document.getElementById('school_class_field');
        let schoolClassSelect = document.getElementById('school_class_id');

        if (roleSelect.value === 'students') {
            schoolField.style.display = 'block';
            schoolClassSelect.setAttribute('required', 'required');
        } else {
            schoolField.style.display = 'none';
            schoolClassSelect.removeAttribute('required');
            schoolClassSelect.value = "";
        }
    });

    document.querySelector('form').addEventListener('submit', function(e) {
        let roleSelect = document.getElementById('role');
        let schoolClassSelect = document.getElementById('school_class_id');
        
        if (roleSelect.value !== 'students') {
            schoolClassSelect.removeAttribute('name');
        }
    });
</script>
@endsection
