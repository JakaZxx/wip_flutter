<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <title>@yield('title') - 4LLAset</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
  <link rel="stylesheet" href="{{ asset('/css/MainCss/sidebar.css') }}">
  <link href="https://unpkg.com/boxicons@2.1.2/css/boxicons.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link rel="icon" href="{{ asset('favicon-v2.png') }}" type="image/png">
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script src="https://js.pusher.com/8.2.0/pusher.min.js"></script>
  @stack('styles')
  <style>
    .avatar-wrapper {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      overflow: hidden;
      flex-shrink: 0;
      margin-right: 6px;
      background: #f3f4f6;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .avatar-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      border-radius: 50%;
      display: block;
    }
    .avatar-placeholder {
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #e5e7eb;
      color: #6b7280;
      font-size: 14px;
      border-radius: 50%;
    }

    .notification-dot {
      background: #ef4444;
      color: white;
      border-radius: 50%;
      padding: 2px 6px;
      font-size: 0.75rem;
      font-weight: bold;
      margin-left: 8px;
    }

    .account-section {
      padding: 8px 16px;
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
      color: #6b7280;
      border-top: 1px solid #e5e7eb;
      margin-top: 10px;
      margin-bottom: 5px;
    }

    .settings-dropdown {
      display: none;
      position: absolute;
      bottom: calc(100% + 10px);
      left: 15px;
      width: 200px;
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      padding: 8px 0;
      z-index: 100;
      overflow: hidden;
    }
    .settings-dropdown li {
      margin: 0;
    }
    .settings-dropdown .nav-link {
      display: flex;
      align-items: center;
      padding: 8px 12px;
      font-size: 14px;
      color: #333;
      transition: all 0.3s ease;
    }
    .settings-dropdown .nav-link i {
      width: 24px;
      text-align: center;
      margin-right: 8px;
    }
    .settings-dropdown .nav-link:hover {
      background: linear-gradient(90deg, #2563eb, #3b82f6);
      color: #fff;
    }

    .settings-dropdown .logout-btn {
      width: 100%;
      text-align: left;
      background: transparent;
      border: none;
      display: flex;
      align-items: center;
      padding: 8px 12px;
      font-size: 14px;
      color: #dc2626;
      cursor: pointer;
      transition: all 0.3s ease;
      gap: 8px;
    }
    .settings-dropdown .logout-btn i {
      width: 24px;
      text-align: center;
      margin-right: 8px;
    }
    .settings-dropdown .logout-btn:hover {
      background: #dc2626;
      color: #fff;
    }

    body {
      overflow-x: hidden;
    }
  </style>
</head>
<body>
  <div class="menu-toggle"><i class="bx bx-chevron-right toggle-icon"></i></div>
  {{-- Removed notification bell for officers here to move it to dashboard blade --}}
  {{-- @if(Auth::check() && Auth::user()->role === 'officers')
    <div class="notification-bell" style="position: fixed; top: 10px; right: 10px; z-index: 1001; cursor: pointer;">
      <i id="global-notification-bell" class="fas fa-bell fa-2x" style="color: #2980b9;"></i>
      <span id="global-notification-badge" style="position: absolute; top: -5px; right: -5px; background: red; color: white; border-radius: 50%; padding: 3px 7px; font-size: 0.75rem; display: none;"></span>
      <div id="global-notification-dropdown" style="display: none; position: absolute; right: 0; top: 30px; background: white; width: 300px; max-height: 400px; overflow-y: auto; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-radius: 8px; z-index: 1000;">
        <div id="global-notification-list" style="padding: 10px;">
          <p style="color: #666;">Memuat notifikasi...</p>
        </div>
      </div>
    </div>
  @endif --}}
  <div class="sidebar" id="sidebar">
    <div class="sidebar-header">
      <img src="{{ asset('ASSETS/4ALL.png') }}" alt="Logo" />
      <span>4LLAset</span>
    </div>
    <div class="sidebar-content">
      <ul class="lists">
        @auth
          @if(Auth::user()->role === 'admin')
            <li>
              <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                <i class="bx bx-home-alt icon"></i> Dashboard
              </a>
            </li>
            <li>
              <a href="{{ route('borrowing.request.create') }}" class="nav-link {{ request()->routeIs('borrowing.request.create') ? 'active' : '' }}">
                <i class="bx bx-plus-circle icon"></i> Peminjaman Aset
              </a>
            </li>
            <li>
              <a href="{{ route('admin.borrowings.index') }}" class="nav-link {{ request()->routeIs('admin.borrowings.index') ? 'active' : '' }}">
                <i class="bx bx-book-content icon"></i> Kelola Peminjaman
                @if(Auth::user()->isAdmin() && Auth::user()->getPendingBorrowingsCountForAdmin() > 0)
                  <span class="notification-dot">{{ Auth::user()->getPendingBorrowingsCountForAdmin() }}</span>
                @endif
              </a>
            </li>
            <li>
              <a href="javascript:void(0)" class="nav-link" id="masterDataBtn">
                <i class="bx bx-folder icon"></i> Kelola Data
                <i class="bx bx-chevron-down" style="margin-left:auto;"></i>
              </a>
              <ul class="submenu" id="masterDataMenu">
                <li>
                  <a href="{{ route('admin.assets.index') }}" class="nav-link {{ request()->routeIs('admin.assets.*') ? 'active' : '' }}">
                    <i class="bx bx-package icon"></i> Unit Kerja
                  </a>
                </li>
                <li>
                  <a href="{{ route('users.index') }}" class="nav-link {{ request()->routeIs('users.*') ? 'active' : '' }}">
                    <i class="bx bx-user icon"></i> Kelola User
                  </a>
                </li>
                <li>
                  <a href="{{ route('admin.classes.index') }}" class="nav-link {{ request()->routeIs('admin.classes.*') ? 'active' : '' }}">
                    <i class="bx bx-chalkboard icon"></i> Kelola Kelas
                  </a>
                </li>
              </ul>
            </li>
          @elseif(Auth::user()->role === 'students')
            <li>
              <a href="{{ route('students.dashboard') }}" class="nav-link {{ request()->routeIs('students.dashboard') ? 'active' : '' }}">
                <i class="bx bx-home-alt icon"></i> Dashboard
              </a>
            </li>
            <li>
              <a href="{{ route('borrowing.request.create.student') }}" class="nav-link {{ request()->routeIs('borrowing.request.create.student') ? 'active' : '' }}">
                <i class="bx bx-plus-circle icon"></i> Peminjaman Aset
              </a>
            </li>
            <li>
              <a href="{{ route('students.borrowings.index') }}" class="nav-link">
                  <i class="bx bx-list-check icon"></i>
                  Status Peminjaman
                  @if(Auth::user()->isStudent() && Auth::user()->getUpdatedBorrowingsCount() > 0)
                    <span class="notification-dot">{{ Auth::user()->getUpdatedBorrowingsCount() }}</span>
                  @endif
              </a>
            </li>
          @elseif(Auth::user()->role === 'officers')
            <li>
              <a href="{{ route('officers.dashboard') }}" class="nav-link {{ request()->routeIs('officers.dashboard') ? 'active' : '' }}">
                <i class="bx bx-home-alt icon"></i> Dashboard
              </a>
            </li>
            <li>
              <a href="javascript:void(0)" class="nav-link" id="officerMasterDataBtn">
                <i class="bx bx-folder icon"></i> Kelola Data
                <i class="bx bx-chevron-down" style="margin-left:auto;"></i>
              </a>
              <ul class="submenu" id="officerMasterDataMenu">
                <li>
                  <a href="{{ route('officers.assets.index') }}" class="nav-link {{ request()->routeIs('officers.assets.*') ? 'active' : '' }}">
                    <i class="bx bx-package icon"></i> Unit Kerja
                  </a>
                </li>
                <li>
                  <a href="{{ route('officers.classes.index') }}" class="nav-link {{ request()->routeIs('officers.classes.*') ? 'active' : '' }}">
                    <i class="bx bx-chalkboard icon"></i> Kelola Kelas
                  </a>
                </li>
              </ul>
            </li>
            <li>
              <a href="{{ route('borrowing.request.create.officers') }}" class="nav-link {{ request()->routeIs('borrowing.request.create.officer') ? 'active' : '' }}">
                <i class="bx bx-plus-circle icon"></i> Peminjaman Aset
              </a>
            </li>
            <li>
              <a href="{{ route('officers.borrowings.index') }}" class="nav-link {{ request()->routeIs('officers.borrowings.index') ? 'active' : '' }}">
                <i class="bx bx-book-content icon"></i> Kelola Peminjaman
                @if(Auth::user()->isOfficer() && Auth::user()->getPendingBorrowingsCount() > 0)
                  <span class="notification-dot">{{ Auth::user()->getPendingBorrowingsCount() }}</span>
                @endif
              </a>
            </li>
            <li>
              <a href="{{ route('officers.borrowings.my') }}" class="nav-link {{ request()->routeIs('officers.borrowings.my') ? 'active' : '' }}">
                  <i class="bx bx-list-check icon"></i>
                  Status Peminjaman Saya
              </a>
            </li>
          @endif
        @else
          <li>
            <a href="{{ route('login') }}" class="nav-link {{ request()->routeIs('login') ? 'active' : '' }}">
              <i class="bx bx-log-in icon"></i> Login
            </a>
          </li>
          <li>
            <a href="{{ route('register') }}" class="nav-link {{ request()->routeIs('register') ? 'active' : '' }}">
              <i class="bx bx-user-plus icon"></i> Register
            </a>
          </li>
        @endauth
      </ul>
    </div>


    <div class="account-section">Account</div>
      <ul class="lists">
        @auth
          <li style="position: relative;">
            <a href="#"
               class="nav-link settings-toggle flex items-center px-3 py-1.5"
               id="settingsToggle">

               <div class="avatar-wrapper">
                @if(Auth::user()->profile_picture && Auth::user()->profile_picture !== 'uploads/profile_pictures/default.png')
                  <img src="{{ asset('storage/'.Auth::user()->profile_picture) }}"
                       alt="Profile"
                       class="avatar-img">
                @else
                  <img src="{{ asset('uploads/profile_pictures/default.png') }}"
                       alt="Default Profile"
                       class="avatar-img">
                @endif
              </div>

              <span class="truncate">{{ Auth::user()->name }}</span>
              <i class="bx bx-chevron-down ml-auto text-sm"></i>
            </a>


            <ul class="settings-dropdown" id="settingsDropdown">
              <li>
                <a href="{{ route('profile') }}" class="nav-link">
                  <i class="bx bx-cog icon"></i> Pengaturan Akun
                </a>
              </li>
              <li>
                <a href="{{ route('bugreport.form') }}" class="nav-link">
                  <i class="bx bx-error-circle"></i> Laporkan Bug
                </a>
              </li>
              <li>
                <form id="logoutForm" action="{{ route('logout') }}" method="POST" style="margin:0;padding:0;">
                  @csrf
                  <button type="submit" class="logout-btn">
                    <i class="bx bx-log-out icon"></i> Logout
                  </button>
                </form>
              </li>
            </ul>
          </li>
        @endauth
      </ul>
    </div>
  </div>

  <main>
    @yield('content')
  </main>

    <script>
      const menuToggle = document.querySelector('.menu-toggle');
      const sidebar = document.getElementById('sidebar');
      const logoutForm = document.getElementById('logoutForm');
      const masterBtn = document.getElementById('masterDataBtn');
      const masterMenu = document.getElementById('masterDataMenu');
      const officerMasterBtn = document.getElementById('officerMasterDataBtn');
      const officerMasterMenu = document.getElementById('officerMasterDataMenu');
      const settingsToggle = document.getElementById('settingsToggle');
      const settingsDropdown = document.getElementById('settingsDropdown');
      const darkModeToggle = document.getElementById('darkModeToggle');

      menuToggle.addEventListener('click', () => {
        sidebar.classList.toggle('open');
        menuToggle.classList.toggle('open');
        const toggleIcon = menuToggle.querySelector('.toggle-icon');
        if (sidebar.classList.contains('open')) {
          toggleIcon.className = 'bx bx-chevron-left toggle-icon';
        } else {
          toggleIcon.className = 'bx bx-chevron-right toggle-icon';
        }
      });

      if (logoutForm) {
        logoutForm.addEventListener('submit', function(e) {
          e.preventDefault();
          Swal.fire({
            title: 'Yakin ingin logout?',
            text: "Kamu akan keluar dari dashboard.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Ya, logout!',
            cancelButtonText: 'Batal'
          }).then((result) => {
            if (result.isConfirmed) logoutForm.submit();
          });
        });
      }

      const submenuActive = masterMenu ? masterMenu.querySelector('.active') : null;
      if (submenuActive) {
        masterMenu.style.display = 'block';
      }
      if (masterBtn) {
        masterBtn.addEventListener('click', () => {
          if (submenuActive) {
            masterMenu.style.display = 'block';
          } else {
            masterMenu.style.display = masterMenu.style.display === 'block' ? 'none' : 'block';
          }
        });
      }
      if (officerMasterBtn) {
        officerMasterBtn.addEventListener('click', () => {
          officerMasterMenu.style.display = officerMasterMenu.style.display === 'block' ? 'none' : 'block';
        });
      }

      // Profil dropdown functionality
      settingsToggle.addEventListener('click', (e) => {
        e.preventDefault();
        if (settingsDropdown.style.display === 'block' || settingsDropdown.style.display === '') {
          settingsDropdown.style.display = 'none';
        } else {
          // Close any other open dropdowns if needed
          settingsDropdown.style.display = 'block';
        }
      });

      // Dark mode toggle functionality
      const isDarkMode = localStorage.getItem('darkMode') === 'true';
      if (isDarkMode) {
        document.body.classList.add('dark-mode');
        darkModeToggle.innerHTML = '<i class="bx bx-sun icon"></i> Tema Terang';
      }

      darkModeToggle.addEventListener('click', (e) => {
        e.preventDefault();
        const isDark = document.body.classList.toggle('dark-mode');
        localStorage.setItem('darkMode', isDark);

        if (isDark) {
          darkModeToggle.innerHTML = '<i class="bx bx-sun icon"></i> Tema Terang';
        } else {
          darkModeToggle.innerHTML = '<i class="bx bx-moon icon"></i> Ubah Tema';
        }
      });

      // Close dropdown when clicking outside
      document.addEventListener('click', (e) => {
        if (!settingsToggle.contains(e.target) && !settingsDropdown.contains(e.target)) {
          settingsDropdown.style.display = 'none';
        }
      });

      // Hide notification dot when clicking on menu with dot
      document.addEventListener('DOMContentLoaded', function() {
        // Admin Kelola Peminjaman
        const adminBorrowingsLink = document.querySelector('a[href="{{ route("admin.borrowings.index") }}"]');
        if (adminBorrowingsLink) {
          adminBorrowingsLink.addEventListener('click', function() {
            const dot = this.querySelector('.notification-dot');
            if (dot) dot.style.display = 'none';
          });
        }

        // Students Status Peminjaman
        const studentBorrowingsLink = document.querySelector('a[href="{{ route("students.borrowings.index") }}"]');
        if (studentBorrowingsLink) {
          studentBorrowingsLink.addEventListener('click', function() {
            const dot = this.querySelector('.notification-dot');
            if (dot) dot.style.display = 'none';
          });
        }

        // Officers Kelola Peminjaman
        const officerBorrowingsLink = document.querySelector('a[href="{{ route("officers.borrowings.index") }}"]');
        if (officerBorrowingsLink) {
          officerBorrowingsLink.addEventListener('click', function() {
            const dot = this.querySelector('.notification-dot');
            if (dot) dot.style.display = 'none';
          });
        }
      });

      // Hide notification dot when clicking on sidebar menu items
      document.addEventListener('click', function(e) {
        const navLink = e.target.closest('.nav-link');
        if (navLink) {
          const dot = navLink.querySelector('.notification-dot');
          if (dot) {
            dot.style.display = 'none';
          }
        }
      });

      // Real-time notifications using Pusher
      @if(Auth::check())
      const pusher = new Pusher('{{ env("PUSHER_APP_KEY") }}', {
        cluster: '{{ env("PUSHER_APP_CLUSTER") }}',
        encrypted: true,
        auth: {
          headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          },
        },
      });

      const channel = pusher.subscribe('notifications.{{ Auth::id() }}');

      channel.bind('notification.sent', function(data) {
        // Show browser notification
        if (Notification.permission === 'granted') {
          new Notification('4LLAset - Notifikasi Baru', {
            body: data.message,
            icon: '{{ asset("favicon-v2.png") }}',
          });
        } else if (Notification.permission !== 'denied') {
          Notification.requestPermission().then(function(permission) {
            if (permission === 'granted') {
              new Notification('4LLAset - Notifikasi Baru', {
                body: data.message,
                icon: '{{ asset("favicon-v2.png") }}',
              });
            }
          });
        }

        // Update notification dots in sidebar
        const notificationDots = document.querySelectorAll('.notification-dot');
        notificationDots.forEach(dot => {
          let currentCount = parseInt(dot.textContent) || 0;
          dot.textContent = currentCount + 1;
          dot.style.display = 'inline-block';
        });

        // Optional: Show a toast notification
        Swal.fire({
          toast: true,
          position: 'top-end',
          showConfirmButton: false,
          timer: 5000,
          timerProgressBar: true,
          icon: 'info',
          title: 'Notifikasi Baru',
          text: data.message,
        });
      });
      @endif
    </script>
    @stack('scripts')
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68tSYb3/4gY" crossorigin="anonymous"></script>
</body>
</html>