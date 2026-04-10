@extends('layouts.app')

@section('title', 'Kelola Kelas')

@section('content')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="{{ asset('css/admin/classes/index.css') }}">

<div class="wrapper">
    <h2>Kelola Kelas</h2>

    <div style="display: flex; gap: 10px; margin-bottom: 20px;">
        <a href="{{ route('admin.classes.create') }}" class="btn-add">
            <i class="fas fa-plus"></i> Tambah Kelas
        </a>

        <!-- Import Classes Button -->
        <button type="button" class="btn-add" style="background: linear-gradient(90deg, #28a745, #20c997);" onclick="toggleImportForm()">
            <i class="fas fa-upload"></i> Import Kelas
        </button>
    </div>

    <!-- Import Classes Form -->
    <div id="import-classes-form">
        <h5 style="margin-bottom: 15px; color: #333;">Import Data Kelas</h5>
        <form action="{{ route('admin.import.classes') }}" method="POST" enctype="multipart/form-data">
            @csrf
            <div class="mb-3">
                <label for="classes_file" class="form-label">Pilih File Excel</label>
                <input type="file" class="form-control" id="classes_file" name="file" accept=".xlsx,.csv" required>
            </div>
            <div style="display: flex; gap: 10px;">
                <button type="submit" class="btn btn-success">
                    <i class="fas fa-upload"></i> Import
                </button>
                <button type="button" class="btn btn-secondary" onclick="toggleImportForm()">
                    <i class="fas fa-times"></i> Batal
                </button>
            </div>
        </form>
        <small class="text-muted mt-2 d-block">Format: nama_kelas, tingkat, program_studi, kapasitas</small>
    </div>

    {{-- Tabel & Pagination tetap sama --}}
    <div class="table-responsive">
        <table class="table-custom">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Nama Kelas</th>
                    <th>Tingkat</th>
                    <th>Program Studi</th>
                    <th>Kapasitas</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($classes as $index => $class)
                    <tr>
                        <td>{{ $index + 1 }}</td>
                        <td>{{ $class->name }}</td>
                        <td>{{ $class->level }}</td>
                        <td>{{ $class->program_study }}</td>
                        <td>{{ $class->capacity }} siswa</td>
                        <td>
                            <a href="{{ route('admin.classes.edit', $class) }}" class="btn-action btn-edit" title="edit">
                                <i class="fas fa-edit"></i>
                            </a>
                            <form action="{{ route('admin.classes.destroy', $class) }}" method="POST" style="display:inline-block" onsubmit="return confirm('Yakin ingin menghapus kelas ini?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn-action btn-delete" title="delete">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="text-center">Tidak ada data kelas</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-3 d-flex justify-content-center">
        {{ $classes->links() }}
    </div>
</div>

<script>
function toggleImportForm() {
    const form = document.getElementById('import-classes-form');
    form.classList.toggle('show');
}
</script>
@endsection