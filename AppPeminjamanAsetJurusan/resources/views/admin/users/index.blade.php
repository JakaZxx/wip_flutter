@extends('layouts.app')

@section('title', 'Kelola User')

@section('content')
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
<link rel="stylesheet" href="{{ asset('css/admin/users/index.css') }}">

<div class="container">
    <h1>Kelola User</h1>
    
    @if(session('success'))
        <div class="alert alert-success" style="background-color: #d4edda; color: #155724; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
            {{ session('success') }}
        </div>
    @endif

    @if(session('error'))
        <div class="alert alert-danger" style="background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
            {{ session('error') }}
        </div>
    @endif

    <a href="{{ route('users.create') }}" class="btn btn-primary"><i class="fas fa-plus"></i> Tambah User</a>

    <form method="GET" action="{{ route('users.index') }}" class="search-form" style="display: flex; gap: 10px; margin: 20px 0; align-items: center;">
        <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama / email..." style="padding: 8px 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; flex: 1;">
        <select name="role" onchange="this.form.submit()" style="padding: 8px 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; flex: 1;">
            <option value="">Semua Role</option>
            @foreach($roleList as $role)
                <option value="{{ $role }}" {{ request('role') == $role ? 'selected' : '' }}>
                    {{ ucfirst($role) }}
                </option>
            @endforeach
        </select>
        <button type="submit" style="display: inline-flex; align-items: center; background: linear-gradient(90deg, #007bff, #0056b3); color: #fff; padding: 8px 14px; border-radius: 6px; text-decoration: none; font-size: 13px; font-weight: 500; transition: background-color 0.2s; cursor: pointer; border: none;">
            <i class="fas fa-search"></i> Cari
        </button>
    </form>

    <table class="table">
        <thead>
            <tr>
                <th>Nama</th>
                <th>Email</th>
                <th>Role</th>
                <th>Jurusan</th>
                <th>Status</th>
                <th class="text-center">Aksi</th>
            </tr>
        </thead>
        <tbody>
            @foreach($users as $user)
            <tr>
                <td data-label="Name">{{ $user->name }}</td>
                <td data-label="Email">{{ $user->email }}</td>
                <td data-label="Role">{{ $user->role }}</td>
                <td data-label="Jurusan">{{ $user->jurusan ?? ($user->isStudent() ? ($user->student?->schoolClass?->program_study ?? '-') : '-') }}</td>
                <td data-label="Status">
                    @if($user->role === 'officers')
                        @if($user->approval_status === 'approved')
                            <span style="color: green;">Approved</span>
                        @elseif($user->approval_status === 'rejected')
                            <span style="color: red;">Rejected</span>
                        @else
                            <span style="color: orange;">Pending</span>
                        @endif
                    @elseif($user->role === 'students')
                        @if($user->email_verified_at)
                            <span style="color: green;">Verified</span>
                        @else
                            <span style="color: red;">Unverified</span>
                        @endif
                    @else
                        -
                    @endif
                </td>
                <td data-label="Actions" class="text-center">
                    <div class="action-buttons">
                        @if($user->role === 'officers' && $user->approval_status === 'pending')
                            <form action="{{ route('users.approve', $user->id) }}" method="POST" style="display:inline;">
                                @csrf
                                @method('PATCH')
                                <button type="submit" class="btn-icon" style="background-color: #28a745;" title="Approve">
                                    <i class="fas fa-check"></i>
                                </button>
                            </form>
                            <form action="{{ route('users.reject', $user->id) }}" method="POST" style="display:inline;">
                                @csrf
                                @method('PATCH')
                                <button type="submit" class="btn-icon" style="background-color: #dc3545;" title="Reject">
                                    <i class="fas fa-times"></i>
                                </button>
                            </form>
                        @endif
                        <a href="{{ route('users.edit', $user->id) }}" class="btn-icon btn-edit" title="Edit">
                            <i class="fas fa-edit"></i>
                        </a>
                        <form action="{{ route('users.destroy', $user->id) }}" method="POST" style="display:inline;" class="form-delete">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn-icon btn-delete btn-confirm" title="Delete">
                                <i class="fas fa-trash"></i>
                            </button>
                        </form>
                    </div>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="pagination-container">
        <div class="entries-info">
            Showing {{ $users->firstItem() }} to {{ $users->lastItem() }} of {{ $users->total() }} entries
        </div>
        <ul class="pagination">
            @if ($users->onFirstPage())
                <li class="disabled"><span>Previous</span></li>
            @else
                <li><a href="{{ $users->previousPageUrl() }}">Previous</a></li>
            @endif

            @foreach ($users->onEachSide(1)->links()->elements as $element)
                @if (is_string($element))
                    <li class="disabled"><span>{{ $element }}</span></li>
                @endif

                @if (is_array($element))
                    @foreach ($element as $page => $url)
                        @if ($page == $users->currentPage())
                            <li class="active"><span>{{ $page }}</span></li>
                        @else
                            <li><a href="{{ $url }}">{{ $page }}</a></li>
                        @endif
                    @endforeach
                @endif
            @endforeach

            @if ($users->hasMorePages())
                <li><a href="{{ $users->nextPageUrl() }}">Next</a></li>
            @else
                <li class="disabled"><span>Next</span></li>
            @endif
        </ul>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const deleteButtons = document.querySelectorAll('.btn-confirm');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function () {
            const form = this.closest('form');
            Swal.fire({
                title: 'Yakin mau hapus user ini?',
                text: "Tindakan ini tidak bisa dibatalkan.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Ya, hapus!',
                cancelButtonText: 'Batal'
            }).then((result) => {
                if (result.isConfirmed) {
                    form.submit();
                }
            });
        });
    });
});
</script>
@endsection
    