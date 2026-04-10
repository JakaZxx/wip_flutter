@extends('layouts.dashboard')

@section('content')
<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <h4>Import Data Excel</h4>
                </div>
                <div class="card-body">
                    @if(session('success'))
                        <div class="alert alert-success">
                            {{ session('success') }}
                        </div>
                    @endif

                    @if(session('error'))
                        <div class="alert alert-danger">
                            {{ session('error') }}
                        </div>
                    @endif

                    <div class="row">
                        <!-- Import Users -->
                        <div class="col-md-4">
                            <div class="card">
                                <div class="card-header">
                                    <h5>Import Users (Students & Officers)</h5>
                                </div>
                                <div class="card-body">
                                    <form action="{{ route('admin.import.users') }}" method="POST" enctype="multipart/form-data">
                                        @csrf
                                        <div class="mb-3">
                                            <label for="users_file" class="form-label">Pilih File Excel</label>
                                            <input type="file" class="form-control" id="users_file" name="file" accept=".xlsx,.csv" required>
                                        </div>
                                        <button type="submit" class="btn btn-primary">Import Users</button>
                                    </form>
                                    <small class="text-muted">Format: nama, email, nis (opsional), role (students/officers), nama_kelas (jika students)</small>
                                </div>
                            </div>
                        </div>

                        <!-- Import Assets -->
                        <div class="col-md-4">
                            <div class="card">
                                <div class="card-header">
                                    <h5>Import Assets</h5>
                                </div>
                                <div class="card-body">
                                    <form action="{{ route('admin.import.assets') }}" method="POST" enctype="multipart/form-data">
                                        @csrf
                                        <div class="mb-3">
                                            <label for="assets_file" class="form-label">Pilih File Excel</label>
                                            <input type="file" class="form-control" id="assets_file" name="file" accept=".xlsx,.csv" required>
                                        </div>
                                        <button type="submit" class="btn btn-primary">Import Assets</button>
                                    </form>
                                    <small class="text-muted">Format: nama_aset, kode, kategori, kondisi, jumlah, deskripsi, lokasi</small>
                                </div>
                            </div>
                        </div>

                        <!-- Import Classes & Students -->
                        <div class="col-md-4">
                            <div class="card">
                                <div class="card-header">
                                    <h5>Import Classes & Students</h5>
                                </div>
                                <div class="card-body">
                                    <form action="{{ route('admin.import.classes-students') }}" method="POST" enctype="multipart/form-data">
                                        @csrf
                                        <div class="mb-3">
                                            <label for="classes_file" class="form-label">Pilih File Excel</label>
                                            <input type="file" class="form-control" id="classes_file" name="file" accept=".xlsx,.csv" required>
                                        </div>
                                        <button type="submit" class="btn btn-primary">Import Classes & Students</button>
                                    </form>
                                    <small class="text-muted">Format: nama_kelas, wali_kelas, nis, nama_siswa, email_siswa</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
