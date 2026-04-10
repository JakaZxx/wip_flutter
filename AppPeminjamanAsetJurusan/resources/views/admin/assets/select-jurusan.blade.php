@extends('layouts.app')

@section('title', 'Pilih Jurusan')

@section('content')
<style>
    /* Animasi muncul dari bawah */
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(40px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    .slide-up {
        opacity: 0;
        animation: slideUp 0.6s ease forwards;
    }
</style>

<div class="container-custom slide-up" style="max-width: 600px; margin: 40px auto; padding: 25px; background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
    <h1 class="slide-up" style="font-size: 24px; font-weight: 600; margin-bottom: 20px; color: #333; animation-delay: 0.1s;">
        Pilih Jurusan
    </h1>

    <!-- View All Button -->
    <div class="slide-up" style="margin-bottom: 25px; animation-delay: 0.2s;">
        <a href="{{ route('admin.assets.index', ['view_all' => '1']) }}"
           style="display: inline-flex; align-items: center; gap: 8px; padding: 12px 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-decoration: none; border-radius: 8px; font-weight: 600; box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3); transition: all 0.3s ease;">
            <i class="fas fa-eye"></i> Lihat Semua Barang
        </a>
        <p style="margin-top: 8px; margin-bottom: 0; font-size: 12px; color: #6c757d;">
            <i class="fas fa-info-circle"></i> Lihat semua aset dari semua jurusan tanpa filter
        </p>
    </div>

    <div style="display: flex; flex-wrap: wrap; gap: 15px;">
        @foreach($jurusanList as $jurusan)
            @php
                $colors = [
                    'Rekayasa Perangkat Lunak' => '#28a745',
                    'Desain Komunikasi Visual' => '#6f42c1',
                    'Teknik Otomasi Industri' => '#6c757d',
                    'Teknik Instalasi Tenaga Listrik' => '#0d6efd',
                    'Teknik Audio Video' => '#ffc107',
                    'Teknik Komputer Jaringan' => '#dc3545',
                ];
                $icons = [
                    'Rekayasa Perangkat Lunak' => 'fa-laptop-code',
                    'Desain Komunikasi Visual' => 'fa-palette',
                    'Teknik Otomasi Industri' => 'fa-cogs',
                    'Teknik Instalasi Tenaga Listrik' => 'fa-bolt',
                    'Teknik Audio Video' => 'fa-video',
                    'Teknik Komputer Jaringan' => 'fa-network-wired',
                ];
                $color = $colors[$jurusan] ?? '#007bff';
                $icon = $icons[$jurusan] ?? 'fa-book';
            @endphp
            <a href="{{ route('admin.assets.index', ['jurusan' => $jurusan]) }}" 
               class="slide-up"
               style="flex: 1 1 45%; padding: 15px; background: {{ $color }}; color: white; text-align: center; border-radius: 8px; text-decoration: none; font-weight: 600; box-shadow: 0 2px 6px rgba(0,0,0,0.1); transition: background-color 0.3s; display: flex; align-items: center; justify-content: center; gap: 8px; animation-delay: {{ $loop->index * 0.15 + 0.3 }}s;">
                <i class="fas {{ $icon }}"></i> {{ $jurusan }}
            </a>
        @endforeach
    </div>
</div>
@endsection
