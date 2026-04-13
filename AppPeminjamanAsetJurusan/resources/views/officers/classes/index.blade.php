@extends('layouts.app')

@section('title', 'Kelola Kelas')

@section('content')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
/* ====== Layout Wrapper ====== */
.wrapper {
    max-width: 100%;
    margin: 40px auto;
    padding: 25px;
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 6px 24px rgba(0, 0, 0, 0.07);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    animation: fadeIn 0.4s ease;
}

/* ====== Header Title ====== */
.wrapper h2 {
    text-align: center;
    font-size: 26px;
    font-weight: 600;
    margin-bottom: 25px;
    color: #2c3e50;
}

/* ====== Buttons (Tambah & Import) ====== */
.btn-add {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 10px 16px;
    background: linear-gradient(135deg, #007bff, #0056b3);
    color: #fff;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 500;
    text-decoration: none;
    transition: all 0.3s ease;
    border: none;
    cursor: pointer;
}
.btn-add:hover {
    transform: translateY(-2px);
    background: linear-gradient(135deg, #0056b3, #003c8f);
}

/* Import Button Color Variant */
.btn-import {
    background: linear-gradient(135deg, #28a745, #20c997);
}
.btn-import:hover {
    background: linear-gradient(135deg, #218838, #1eae84);
}

/* ====== Table Style ====== */
.table-custom {
    width: 100%;
    border-collapse: collapse;
    overflow: hidden;
    border-radius: 10px;
}

.table-custom thead {
    background: #f4f6f8;
    color: #2c3e50;
}
.table-custom th,
.table-custom td {
    padding: 14px 16px;
    text-align: left;
    font-size: 15px;
    border-bottom: 1px solid #e5e5e5;
}
.table-custom tr:hover {
    background: #f9fbff;
}

/* ====== Action Buttons ====== */
.btn-action {
    width: 36px;
    height: 36px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    font-size: 16px;
    color: #fff;
    transition: all 0.25s ease;
}
.btn-action:hover {
    transform: scale(1.05);
}
.btn-edit {
    background-color: #ffc107;
}
.btn-edit:hover {
    background-color: #e0a800;
}
.btn-delete {
    background-color: #dc3545;
    margin-left: 6px;
}
.btn-delete:hover {
    background-color: #b02a37;
}

/* ====== Animations ====== */
@keyframes fadeInUp {
    from {opacity: 0; transform: translateY(20px);}
    to {opacity: 1; transform: translateY(0);}
}
.fade-in {
    opacity: 0;
    animation: fadeInUp 0.6s ease forwards;
}

/* ====== Pagination Area ====== */
.pagination-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    margin-top: 15px;
    gap: 12px;
}

.entries-info {
    font-size: 13px;
    color: #555;
}

.pagination {
    list-style: none;
    display: flex;
    gap: 6px;
    padding: 0;
    margin: 0;
}

.pagination a,
.pagination span {
    padding: 6px 10px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 13px;
    color: #333;
    text-decoration: none;
    transition: all 0.2s ease;
}

.pagination a:hover {
    background-color: #007bff;
    color: #fff;
    border-color: #007bff;
}

.pagination .active span {
    background-color: #007bff;
    color: #fff;
    border-color: #007bff;
}

.pagination .disabled span {
    color: #aaa;
    background: #f9f9f9;
    cursor: not-allowed;
}

/* ====== Import Form ====== */
#import-classes-form {
    display: none;
    background: #f8f9fa;
    padding: 20px;
    border-radius: 10px;
    border: 1px solid #dee2e6;
    margin-bottom: 20px;
    animation: fadeInUp 0.4s ease;
}

/* ====== Search Filter Bar ====== */
.filter-form {
    margin-bottom: 20px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    align-items: center;
}
.filter-form input,
.filter-form select {
    padding: 8px 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 13px;
    flex: 1;
    min-width: 140px;
}
.filter-form button {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: linear-gradient(135deg, #007bff, #0056b3);
    color: #fff;
    padding: 8px 14px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 500;
    border: none;
    cursor: pointer;
    transition: 0.25s;
}
.filter-form button:hover {
    background: linear-gradient(135deg, #0056b3, #003c8f);
}

/* ====== Responsive Design ====== */
@media (max-width: 768px) {
    .wrapper {
        padding: 18px;
        margin: 20px;
    }
    .wrapper h2 {
        font-size: 22px;
    }
    .table-custom th,
    .table-custom td {
        padding: 8px;
        font-size: 13px;
    }
    .btn-add, .btn-import {
        font-size: 13px;
        padding: 8px 12px;
    }
    .filter-form {
        flex-direction: column;
        align-items: flex-start;
        justify-content: flex-start;
        gap: 8px;
    }
    .filter-form input,
    .filter-form select,
    .filter-form button {
        width: 100%;
    }

    /* Hide Program Studi and Kapasitas columns on mobile */
    .table-custom th:nth-child(4),
    .table-custom td:nth-child(4),
    .table-custom th:nth-child(5),
    .table-custom td:nth-child(5) {
        display: none;
    }
}
</style>
<div class="wrapper fade-in">
    <h2 class="fade-in-delay-1">Kelola Kelas</h2>

    <div style="display: flex; gap: 10px; margin-bottom: 20px;">
        <a href="{{ route('officers.classes.create') }}" class="btn-add fade-in-delay-2">
            <i class="fas fa-plus"></i> Tambah Kelas
        </a>

        <!-- Import Classes Button -->
        <button type="button" class="btn-add" style="background: linear-gradient(90deg, #28a745, #20c997);" onclick="document.getElementById('import-classes-form').style.display='block'">
            <i class="fas fa-upload"></i> Import Kelas
        </button>
    </div>

    <!-- Import Classes Form (Hidden by default) -->
    <div id="import-classes-form" style="display: none; background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #dee2e6;">
        <h5 style="margin-bottom: 15px; color: #333;">Import Data Kelas</h5>
        <form action="{{ route('officers.import.classes') }}" method="POST" enctype="multipart/form-data">
            @csrf
            <div class="mb-3">
                <label for="classes_file" class="form-label">Pilih File Excel</label>
                <input type="file" class="form-control" id="classes_file" name="file" accept=".xlsx,.csv" required>
            </div>
            <div style="display: flex; gap: 10px;">
                <button type="submit" class="btn btn-success">
                    <i class="fas fa-upload"></i> Import
                </button>
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('import-classes-form').style.display='none'">
                    <i class="fas fa-times"></i> Batal
                </button>
            </div>
        </form>
        <small class="text-muted mt-2 d-block">Format: nama_kelas, tingkat, program_studi, kapasitas</small>
    </div>

    <!-- Search & Filter -->
    <form class="filter-form" method="GET" action="{{ route('officers.classes.index') }}"  class="fade-in-delay-3">
        <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama kelas...">
        <select name="level" onchange="this.form.submit()">
            <option value="">Semua Tingkat</option>
            @if(isset($levelList))
                @foreach($levelList as $level)
                    <option value="{{ $level }}" {{ request('level') == $level ? 'selected' : '' }}>
                        {{ $level }}
                    </option>
                @endforeach
            @endif
        </select>
        <select name="program_study" onchange="this.form.submit()">
            <option value="">Semua Program Studi</option>
            @if(isset($programStudyList))
                @foreach($programStudyList as $programStudy)
                    <option value="{{ $programStudy }}" {{ request('program_study') == $programStudy ? 'selected' : '' }}>
                        {{ $programStudy }}
                    </option>
                @endforeach
            @endif
        </select>
        <button type="submit">
            <i class="fas fa-search"></i> Cari
        </button>
    </form>

    @if(session('success'))
        <div class="alert alert-success mb-3 fade-in-delay-3">
            {{ session('success') }}
        </div>
    @endif

    <div class="table-responsive fade-in-delay-4">
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
                            <a href="{{ route('officers.classes.edit', $class) }}" class="btn-action btn-edit" title="edit">
                                <i class="fas fa-edit"></i>
                            </a>
                            <form action="{{ route('officers.classes.destroy', $class) }}" method="POST" style="display:inline-block" onsubmit="return confirm('Yakin ingin menghapus kelas ini?')">
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

        <!-- Pagination Footer -->
        <div class="pagination-container">
            <div class="entries-info">
                Showing {{ $classes->firstItem() }} to {{ $classes->lastItem() }} of {{ $classes->total() }} entries
            </div>
            <ul class="pagination">
                @if ($classes->onFirstPage())
                    <li class="disabled"><span>Previous</span></li>
                @else
                    <li><a href="{{ $classes->previousPageUrl() }}">Previous</a></li>
                @endif

                @foreach ($classes->onEachSide(1)->links()->elements as $element)
                    @if (is_string($element))
                        <li class="disabled"><span>{{ $element }}</span></li>
                    @endif

                    @if (is_array($element))
                        @foreach ($element as $page => $url)
                            @if ($page == $classes->currentPage())
                                <li class="active"><span>{{ $page }}</span></li>
                            @else
                                <li><a href="{{ $url }}">{{ $page }}</a></li>
                            @endif
                        @endforeach
                    @endif
                @endforeach

                @if ($classes->hasMorePages())
                    <li><a href="{{ $classes->nextPageUrl() }}">Next</a></li>
                @else
                    <li class="disabled"><span>Next</span></li>
                @endif
            </ul>
        </div>
    </div>

    <div class="mt-3 d-flex justify-content-center fade-in-delay-4">
        {{ $classes->links() }}
    </div>
@endsection
