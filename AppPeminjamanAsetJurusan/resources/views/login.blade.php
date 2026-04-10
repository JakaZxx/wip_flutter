<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <title>4llAset - Login</title>

  <!-- Tailwind -->
  <link href="https://unpkg.com/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <!-- Google Font -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
  <!-- Lottie -->
  <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>

   <link rel="icon" href="{{ asset('favicon-v2.png') }}" type="image/png">

  <style>
    body { font-family: 'Poppins', sans-serif; }
    .gradient-bg { background: linear-gradient(135deg, #007bff, #0056b3); }
    .animate-fade-in { animation: fadeIn 1s ease-in-out; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    input:focus { outline: none !important; border-color: #007bff !important; box-shadow: 0 0 0 3px rgba(0,123,255,0.3); }
    /* Switch Toggle */
    .switch { position: relative; display:inline-block; width:44px; height:24px; }
    .switch input { opacity:0; width:0; height:0; }
    .slider { position:absolute; cursor:pointer; top:0; left:0; right:0; bottom:0; background-color:#ccc; transition:.4s; border-radius:9999px; }
    .slider:before { position:absolute; content:""; height:18px; width:18px; left:3px; bottom:3px; background:white; transition:.4s; border-radius:50%; }
    input:checked + .slider { background-color:#007bff; }
    input:checked + .slider:before { transform: translateX(20px); }
  </style>
</head>
<body class="gradient-bg min-h-screen flex flex-col">

  <!-- Navbar -->
  <nav class="w-full fixed top-0 z-50 bg-transparent py-4">
    <div class="container mx-auto flex items-center justify-between px-6">
      <a href="{{ url('/') }}" class="flex items-center gap-2 text-white font-bold text-2xl">
        <img src="{{ asset('ASSETS/smkn4.png') }}" alt="Logo" class="h-8 w-auto">
        4llAset
      </a>
      <div class="flex gap-4">
        <!-- Home button -->
        <a href="{{ url('/') }}" class="flex items-center text-white font-semibold py-2 px-5 rounded-lg transition transform duration-300 hover:scale-105 hover:bg-white hover:text-blue-600">
           Home
        </a>
        <a href="{{ url('/#tentang') }}" class="flex items-center text-white font-semibold py-2 px-5 rounded-lg transition transform duration-300 hover:scale-105 hover:bg-white hover:text-blue-600">
            Tentang
        </a>
        <a href="{{ url('/#Jurusan') }}" class="flex items-center text-white font-semibold py-2 px-5 rounded-lg transition transform duration-300 hover:scale-105 hover:bg-white hover:text-blue-600">
            Jurusan
        </a>
      </div>
    </div>
  </nav>

  <!-- Main Section -->
  <section class="flex flex-col lg:flex-row items-center justify-center flex-grow px-6 pt-24 lg:pt-0">
    <!-- Login Form -->
    <div class="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-md text-gray-800 animate-fade-in">
      <div class="flex flex-col items-center mb-6">
        <img src="{{ asset('ASSETS/smkn4.png') }}" alt="Logo" class="h-16 mb-2">
        <h1 class="text-2xl font-bold tracking-wide text-blue-700">4llAset LOGIN</h1>
        <p class="text-gray-500 text-sm mt-2">Isi Email dan Password di bawah untuk lanjut</p>
      </div>

      @if(session('error'))
        <div class="bg-red-500 text-white text-sm px-4 py-2 rounded mb-4">
          {{ session('error') }}
        </div>
      @endif

      <form action="{{ route('login.submit') }}" method="POST" class="space-y-5">
        @csrf

        <div>
          <label class="block text-sm font-semibold mb-1">Email</label>
          <input type="email" name="email" placeholder="Masukkan email" required autocomplete="email"
            class="w-full px-4 py-3 rounded-lg border focus:ring-2 focus:ring-blue-400" />
        </div>

        <div>
          <label class="block text-sm font-semibold mb-1">Password</label>
          <div class="relative">
            <!-- <-- PERBAIKAN: tambahkan name="password" -->
            <input id="password" name="password" type="password" placeholder="Password" autocomplete="current-password"
              class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none">
            
            <!-- Tombol toggle -->
            <button type="button" aria-label="Toggle password visibility" onclick="togglePassword()" class="absolute inset-y-0 right-3 flex items-center">
              <!-- Mata terbuka -->
              <svg id="eyeOpen" xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
              </svg>

              <!-- Mata tertutup -->
              <svg id="eyeClosed" xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-500 hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.269-2.944-9.542-7a9.977 9.977 0 012.332-3.952m3.183-2.34A9.956 9.956 0 0112 5c4.478 0 8.269 2.944 9.542 7a9.963 9.963 0 01-4.043 5.197M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3l18 18"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Switch Remember Me -->
        <div class="flex items-center gap-3">
          <label class="switch">
            <input type="checkbox" id="remember" name="remember">
            <span class="slider"></span>
          </label>
          <span class="text-sm">Remember me</span>
        </div>

        <button type="submit" class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold shadow-md transition transform hover:scale-105">
          Login
        </button>
      </form>

      <div class="text-center mt-4">
        <a href="{{ route('password.forgot.form') }}" class="text-blue-600 hover:text-blue-800 text-sm">Lupa Password?</a>
      </div>
    </div>

    <!-- Lottie Animation -->
    <div class="hidden lg:flex lg:w-1/2 justify-center items-center relative mt-10 lg:mt-0">
      <!-- Background blob putih -->
      <div class="absolute w-80 h-80 bg-white opacity-70 rounded-full blur-2xl transform -rotate-12"></div>
      <div class="absolute w-96 h-96 bg-white opacity-40 rounded-full top-10 left-20 blur-3xl"></div>
      
      <!-- Lottie Animation -->
      <lottie-player 
        src="https://assets4.lottiefiles.com/packages/lf20_jcikwtux.json"  
        background="transparent"  
        speed="1"  
        style="width: 500px; height: 500px; position: relative; z-10;"  
        loop  
        autoplay>
      </lottie-player>
    </div>
  </section>

  <script>
    function togglePassword() {
      const password = document.getElementById("password");
      const eyeOpen = document.getElementById("eyeOpen");
      const eyeClosed = document.getElementById("eyeClosed");

      if (password.type === "password") {
        password.type = "text";
        eyeOpen.classList.add("hidden");
        eyeClosed.classList.remove("hidden");
      } else {
        password.type = "password";
        eyeOpen.classList.remove("hidden");
        eyeClosed.classList.add("hidden");
      }
    }
  </script>
  
</body>
</html>
