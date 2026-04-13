@extends('layouts.app')

@section('title', 'Laporkan Bug')

@section('content')
<style>
    body {
      font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: #f9fafb;
      margin: 0;
      padding: 20px;
      color: #1f2937;
      overflow-x: hidden;
    }

    /* Animasi saat page load */
    @keyframes fadeSlideIn {
      0% {
        opacity: 0;
        transform: translateY(30px);
      }
      100% {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .bug-card {
      max-width: 720px;
      margin: auto;
      background: #ffffff;
      border-radius: 16px;
      padding: 32px;
      box-shadow: 0 8px 28px rgba(0, 0, 0, 0.06);
      opacity: 0;
      animation: fadeSlideIn 0.9s ease-out forwards;
      animation-delay: 0.2s;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    /* Efek hover lembut pada card */
    .bug-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 12px 36px rgba(0, 0, 0, 0.08);
    }

    .bug-card h1 {
      font-size: 1.8rem;
      font-weight: 600;
      color: #111827;
      margin-bottom: 28px;
      text-align: center;
      position: relative;
      opacity: 0;
      animation: fadeSlideIn 1s ease-out forwards;
      animation-delay: 0.3s;
    }

    .bug-card h1::after {
      content: "";
      position: absolute;
      bottom: -10px;
      left: 50%;
      transform: translateX(-50%);
      width: 60px;
      height: 3px;
      background: #ef4444;
      border-radius: 2px;
    }

    .form-group {
      margin-bottom: 20px;
      opacity: 0;
      animation: fadeSlideIn 1s ease forwards;
      animation-delay: 0.4s; /* semua elemen muncul bersamaan */
    }

    label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      font-size: 0.95rem;
      color: #374151;
    }

    textarea,
    select,
    input[type="file"] {
      width: 100%;
      border-radius: 12px;
      border: 1px solid #d1d5db;
      padding: 12px 14px;
      font-size: 0.95rem;
      transition: all 0.25s ease;
      background: #f9fafb;
    }

    textarea {
      min-height: 160px;
      resize: vertical;
      line-height: 1.5;
    }

    textarea:focus,
    select:focus,
    input[type="file"]:focus {
      border-color: #ef4444;
      background: #fff;
      outline: none;
      box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.2);
    }

    /* Alert box */
    .alert {
      padding: 14px 18px;
      border-radius: 10px;
      margin-bottom: 22px;
      font-size: 0.95rem;
      opacity: 0;
      animation: fadeSlideIn 0.8s ease-out forwards;
      animation-delay: 0.3s;
    }

    .alert-success {
      background: #ecfdf5;
      border: 1px solid #10b981;
      color: #065f46;
    }

    .alert-error {
      background: #fef2f2;
      border: 1px solid #ef4444;
      color: #991b1b;
    }

    .alert-error ul {
      margin: 0;
      padding-left: 20px;
    }

    /* Tombol */
    .form-actions {
      display: flex;
      gap: 14px;
      margin-top: 28px;
      opacity: 0;
      animation: fadeSlideIn 1s ease forwards;
      animation-delay: 0.5s;
    }

    .btn {
      flex: 1;
      border: none;
      border-radius: 12px;
      padding: 14px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.25s ease;
      font-size: 1rem;
    }

    .btn-submit {
      background: #ef4444;
      color: #fff;
      box-shadow: 0 4px 10px rgba(239, 68, 68, 0.25);
    }

    .btn-submit:hover {
      background: #dc2626;
      box-shadow: 0 6px 14px rgba(239, 68, 68, 0.35);
      transform: translateY(-2px);
    }

    .btn-cancel {
      background: #e5e7eb;
      color: #374151;
    }

    .btn-cancel:hover {
      background: #d1d5db;
      transform: translateY(-2px);
    }

    /* Responsive */
    @media (max-width: 640px) {
      .form-actions {
        flex-direction: column;
      }

      .btn {
        width: 100%;
      }
    }
</style>

<div class="bug-card">
    <h1>Laporkan Bug</h1>

    @if(session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    @if($errors->any())
        <div class="alert alert-error">
            <ul>
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('bugreport.submit') }}" method="POST" enctype="multipart/form-data">
        @csrf

        <div class="form-group">
            <label for="device_type">Device <span style="color:red">*</span></label>
            <select id="device_type" name="device_type" required>
                <option value="" disabled selected>Pilih Device</option>
                <option value="mobile" {{ old('device_type') == 'mobile' ? 'selected' : '' }}>Mobile</option>
                <option value="desktop" {{ old('device_type') == 'desktop' ? 'selected' : '' }}>Desktop</option>
            </select>
        </div>

        <div class="form-group">
            <label for="bug_type">Jenis Bug <span style="color:red">*</span></label>
            <select id="bug_type" name="bug_type" required>
                <option value="" disabled selected>Pilih Jenis Bug</option>
                <option value="tampilan" {{ old('bug_type') == 'tampilan' ? 'selected' : '' }}>Tampilan</option>
                <option value="sistem" {{ old('bug_type') == 'sistem' ? 'selected' : '' }}>Sistem</option>
            </select>
        </div>

        <div class="form-group">
            <label for="bug_image">Gambar Bug (Opsional)</label>
            <input type="file" id="bug_image" name="bug_image" accept="image/*" />
        </div>

        <div class="form-group">
            <label for="bug_description">Deskripsi Bug <span style="color:red">*</span></label>
            <textarea id="bug_description" name="bug_description" required>{{ old('bug_description') }}</textarea>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-submit">Kirim Laporan Bug</button>
            <a href="{{ url()->previous() }}" class="btn btn-cancel">Batal</a>
        </div>
    </form>
</div>
@endsection
