@extends('layouts.app')

@section('title', 'Profile')

@section('content')

<link rel="stylesheet" href="{{ asset('css/MainCss/profile-settings.css') }}">
<div class="profile-container animate-fade-slide">
    <div class="profile-card">
        <div class="profile-avatar">
            <img id="profileImage"
     src="{{ $user->profile_picture && $user->profile_picture !== 'uploads/profile_pictures/default.png'
              ? asset('storage/'.$user->profile_picture)
              : asset('uploads/profile_pictures/default.png') }}"
     alt="Profile Picture">

        </div>
        <div class="profile-info text-center">
            <h2>{{ $user->name }}</h2>
            <p>{{ $user->email }} <span class="verification-status {{ $user->hasVerifiedEmail() ? 'verified' : 'not-verified' }}">{{ $user->hasVerifiedEmail() ? 'Verified' : 'Not Verified' }}</span></p>
            <span class="role-badge">{{ ucfirst($user->role) }}</span>
            @if($user->student && $user->student->schoolClass)
            <p class="mt-2">{{ $user->student->schoolClass->name }}</p>
            @endif
        </div>
    </div>

    <div class="profile-form">
        <h2 class="text-xl font-bold text-gray-800 mb-6">Pengaturan Akun</h2>

        @if(session('success'))
        <div class="alert alert-success">✅ {{ session('success') }}</div>
        @endif
        @if($errors->any())
        <div class="alert alert-error">
            ❌ Ada kesalahan:
            <ul class="list-disc list-inside text-sm ml-4">
                @foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach
            </ul>
        </div>
        @endif
        <form id="profileForm" action="{{ route('profile.photo.upload') }}" method="POST" enctype="multipart/form-data">
            @csrf
            <div>
                <label>Name</label>
                <p>{{ $user->name }}</p>
            </div>

            <div>
                <label>Email</label>
                <p>{{ $user->email }} <span class="verification-status {{ $user->hasVerifiedEmail() ? 'verified' : 'not-verified' }}">{{ $user->hasVerifiedEmail() ? 'Verified' : 'Not Verified' }}</span></p>
            </div>
            <!-- Role -->
            <div>
                <label>Role</label>
                <p>{{ ucfirst($user->role) }}</p>
            </div>
            @if($user->student)
            <div>
                <label>Class</label>
                <p>{{ $user->student->schoolClass->name ?? 'N/A' }}</p>
            </div>
            @endif
            <div>
                <label for="profile_picture" class="cursor-pointer text-blue px-4 py-2 rounded">Pilih Foto</label>
                <input type="file" id="profile_picture" accept="image/*" class="hidden">
                <input type="hidden" name="cropped_image" id="croppedImageInput">
            </div>
            <div>
                <button type="submit" class="btn btn-blue">Simpan</button>
            </div>
        </form>

        @if($user->profile_picture)
        <form action="{{ route('profile.photo.delete') }}" method="POST" class="mt-4">
            @csrf @method('DELETE')
            <button type="submit" class="btn btn-red">Hapus Foto</button>
        </form>
        @endif
        <div class="mt-4">
            <a href="{{ route('password.forgot.form') }}" class="btn btn-secondary">Lupa Password</a>
        </div>
    </div>
</div>

<div id="cropperModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h5>Crop Image</h5>
      <button class="close" id="closeModal">&times;</button>
    </div>
    <div class="modal-body">
      <img id="cropper-image" src="">
    </div>
    <div class="modal-footer">
      <button class="btn btn-blue" id="cropImageBtn">Crop</button>
      <button class="btn btn-red" id="cancelCropBtn">Batal</button>
    </div>
  </div>
</div>

<link href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css" rel="stylesheet"/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const fileInput = document.getElementById('profile_picture');
    const modal = document.getElementById('cropperModal');
    const closeModalBtn = document.getElementById('closeModal');
    const cancelCropBtn = document.getElementById('cancelCropBtn');
    const cropImageBtn = document.getElementById('cropImageBtn');
    const cropperImage = document.getElementById('cropper-image');
    const profileImage = document.getElementById('profileImage');
    const croppedImageInput = document.getElementById('croppedImageInput');

    let cropper;

    fileInput.addEventListener('change', (e) => {
        if (e.target.files && e.target.files[0]) {
            const file = e.target.files[0];
            const url = URL.createObjectURL(file);
            cropperImage.src = url;
            if (cropper) cropper.destroy();
            cropper = new Cropper(cropperImage, { aspectRatio: 1, viewMode: 2 });
            modal.style.display = 'block';
        }
    });

    function closeModal() {
        modal.style.display = 'none';
        if (cropper) { cropper.destroy(); cropper = null; }
        fileInput.value = '';
    }
    closeModalBtn.addEventListener('click', closeModal);
    cancelCropBtn.addEventListener('click', closeModal);

    cropImageBtn.addEventListener('click', function () {
        if (!cropper) return;
        const canvas = cropper.getCroppedCanvas({ width: 400, height: 400 });
        profileImage.src = canvas.toDataURL();
        croppedImageInput.value = canvas.toDataURL('image/png');
        closeModal();
    });

    window.addEventListener('click', (e) => { if (e.target === modal) closeModal(); });
});
</script> 
@endsection
