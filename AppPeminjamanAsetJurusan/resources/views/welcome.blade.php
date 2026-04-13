<!DOCTYPE html>
<html lang="en">
  <head>
    <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>
      4LLAset
    </title>
    <meta name="description" content="Simple landind page" />
    <meta name="keywords" content="" />
    <meta name="author" content="" />
    <link rel="stylesheet" href="https://unpkg.com/tailwindcss@2.2.19/dist/tailwind.min.css"/>
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:400,700" rel="stylesheet" />
     <link rel="icon" href="{{ asset('favicon-v2.png') }}" type="image/png">
    
    <style>
      .gradient {
        background: linear-gradient(90deg, #007bff, #0056b3);
      }
      
      .gradient-animated {
        background: linear-gradient(-45deg, #007bff, #0056b3, #007bff, #0056b3);
        background-size: 400% 400%;
        animation: gradientShift 8s ease infinite;
      }

      @keyframes gradientShift {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
      }

      html {
        scroll-behavior: smooth;
      }

      #loader {
        transition: opacity 0.8s ease, visibility 0.8s ease;
      }
      #loader.fade-out {
        opacity: 0;
        visibility: hidden;
      }

      body.loading {
        overflow: hidden; /* cegah scroll saat loading */
      }
      body.loading > *:not(#loader) {
        display: none !important;
      }

      /* Enhanced Animations */
      @keyframes fadeUp {
        0% { opacity: 0; transform: translateY(30px) scale(0.95); }
        100% { opacity: 1; transform: translateY(0) scale(1); }
      }

      @keyframes fadeDown {
        0% { opacity: 0; transform: translateY(-30px) scale(0.95); }
        100% { opacity: 1; transform: translateY(0) scale(1); }
      }

      @keyframes fadeZoom {
        0% { opacity: 0; transform: scale(0.8) rotate(-2deg); }
        100% { opacity: 1; transform: scale(1) rotate(0); }
      }

      @keyframes slideInLeft {
        0% { opacity: 0; transform: translateX(-50px); }
        100% { opacity: 1; transform: translateX(0); }
      }

      @keyframes slideInRight {
        0% { opacity: 0; transform: translateX(50px); }
        100% { opacity: 1; transform: translateX(0); }
      }

      @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
      }

      @keyframes float {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-10px); }
      }

      @keyframes bounceIn {
        0% { opacity: 0; transform: scale(0.3); }
        50% { opacity: 1; transform: scale(1.05); }
        70% { transform: scale(0.9); }
        100% { opacity: 1; transform: scale(1); }
      }

      .animate-fadeUp {
        animation: fadeUp 1s ease forwards;
        opacity: 0;
      }
      .animate-fadeDown {
        animation: fadeDown 1s ease forwards;
        opacity: 0;
      }
      .animate-fadeZoom {
        animation: fadeZoom 1s ease forwards;
        opacity: 0;
      }
      .animate-slideInLeft {
        animation: slideInLeft 1s ease forwards;
        opacity: 0;
      }
      .animate-slideInRight {
        animation: slideInRight 1s ease forwards;
        opacity: 0;
      }
      .animate-pulse {
        animation: pulse 2s ease-in-out infinite;
      }
      .animate-float {
        animation: float 3s ease-in-out infinite;
      }
      .animate-bounceIn {
        animation: bounceIn 0.6s ease forwards;
        opacity: 0;
      }

      /* delay helper */
      .delay-100 { animation-delay: 0.1s; }
      .delay-200 { animation-delay: 0.2s; }
      .delay-300 { animation-delay: 0.3s; }
      .delay-400 { animation-delay: 0.4s; }
      .delay-500 { animation-delay: 0.5s; }
      .delay-600 { animation-delay: 0.6s; }
      .delay-700 { animation-delay: 0.7s; }
      .delay-800 { animation-delay: 0.8s; }
      .delay-900 { animation-delay: 0.9s; }
      .delay-1000 { animation-delay: 1s; }

      /* Hover effects */
      .hover-lift {
        transition: transform 0.3s ease, box-shadow 0.3s ease;
      }
      .hover-lift:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
      }

      /* Parallax effect */
      .parallax {
        transform: translateZ(0);
        will-change: transform;
      }
    </style>
  </head>
  <!-- ADDED: class "loading" supaya saat awal hanya loader yang tampak -->
  <body class="leading-normal tracking-normal text-white gradient-animated" style="font-family: 'Source Sans Pro', sans-serif;">
    <!--Nav-->
    <nav id="header" class="fixed w-full z-30 top-0 text-white">
      <div class="w-full container mx-auto flex flex-wrap items-center justify-between mt-0 py-2">
        <div class="pl-4 flex items-center">
        <a class="toggleColour text-white no-underline hover:no-underline font-bold text-2xl lg:text-4xl flex items-center gap-2" href="#">
          <img src="{{ asset('ASSETS/smkn4.png') }}" alt="Logo SMKN 4" class="h-8 w-auto">
          4LLAset
        </a>
        </div>
        <div class="block lg:hidden pr-4">
          <button id="nav-toggle" class="flex items-center p-1 text-white-800 hover:text-gray-900 focus:outline-none focus:shadow-outline transform transition hover:scale-105 duration-300 ease-in-out">
            <svg class="fill-current h-6 w-6" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
              <title>Menu</title>
              <path d="M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" />
            </svg>
          </button>
        </div>
        <div
  class="w-full flex-grow lg:flex lg:items-center lg:justify-end lg:w-auto hidden mt-2 lg:mt-0
         bg-blue-600 lg:bg-transparent text-black p-4 lg:p-0 z-20 rounded-md"
  id="nav-content"
>
  <div class="flex flex-col lg:flex-row lg:items-center lg:space-x-6">
    <ul
      class="list-reset flex flex-col lg:flex-row items-center space-y-2 lg:space-y-0 lg:space-x-6 text-center lg:text-right"
    >
      <li>
        <a
          class="inline-block py-2 px-4 font-bold no-underline toggleColour text-white hover:bg-white hover:text-gray-800 rounded-md transition duration-300 ease-in-out hover:scale-105"
          href="/"
          >Home</a
        >
      </li>
      <li>
        <a
          class="inline-block py-2 px-4 no-underline toggleColour text-white hover:bg-white hover:text-gray-800 rounded-md transition duration-300 ease-in-out hover:scale-105"
          href="#tentang"
          >Tentang</a
        >
      </li>
      <li>
        <a
          class="inline-block py-2 px-4 no-underline toggleColour text-white hover:bg-white hover:text-gray-800 rounded-md transition duration-300 ease-in-out hover:scale-105"
          href="#Jurusan"
          >Jurusan</a
        >
      </li>
    </ul>

    <div class="mt-4 lg:mt-0 flex justify-center">
  <a
    href="{{ route('login') }}"
    id="navAction"
    class="bg-white text-gray-800 font-bold rounded-full py-2 px-6 shadow-md opacity-90 hover:opacity-100 hover:underline transform transition hover:scale-105 duration-300 ease-in-out"
  >
    Login
  </a>
</div>

  </div>
</div>

      </nav>
    <!--Hero-->
    <div class="pt-24">
      <div class="container px-3 mx-auto flex flex-wrap flex-col md:flex-row items-center">
        <!--Left Col-->
          <div id="heroText" class="flex flex-col w-full md:w-2/5 justify-center 
            items-center md:items-start text-center md:text-left">
          <h1 class="my-4 text-5xl font-bold leading-tight">
            4llAset : Aplikasi Peminjaman Aset Sekolah
          </h1>
          <p class="leading-normal text-2xl mb-8">
            Menyediakan platform yang efisien, mudah digunakan, dan terintegrasi untuk pengelolaan serta peminjaman aset sekolah
          </p>
          <a href="{{ route('login') }}">
            <button class="hover:underline bg-white text-gray-800 font-bold rounded-full my-6 py-4 px-8 
                          shadow-lg focus:outline-none focus:shadow-outline transform transition 
                          hover:scale-105 duration-300 ease-in-out">
              Login
            </button>
          </a>
        </div>
        <!--Right Col with Lottie iframe-->
        <div id="heroImage" class="w-full md:w-3/5 py-6">
          <lottie-player 
            src="https://assets4.lottiefiles.com/packages/lf20_jcikwtux.json"  
            background="transparent"  
            speed="1"  
            style="width: 65%; height: 65%;"  
            loop  
            autoplay
            class="block ml-auto">
          </lottie-player>
        </div>
      </div>
    </div>
    <div id="waveSection" class="relative -mt-12 lg:-mt-24">
      <svg viewBox="0 0 1428 174" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
          <g transform="translate(-2.000000, 44.000000)" fill="#FFFFFF" fill-rule="nonzero">
            <path d="M0,0 C90.7283404,0.927527913 147.912752,27.187927 291.910178,59.9119003 C387.908462,81.7278826 543.605069,89.334785 759,82.7326078 C469.336065,156.254352 216.336065,153.6679 0,74.9732496" opacity="0.100000001"></path>
            <path
              d="M100,104.708498 C277.413333,72.2345949 426.147877,52.5246657 546.203633,45.5787101 C666.259389,38.6327546 810.524845,41.7979068 979,55.0741668 C931.069965,56.122511 810.303266,74.8455141 616.699903,111.243176 C423.096539,147.640838 250.863238,145.462612 100,104.708498 Z"
              opacity="0.100000001"
            ></path>
            <path d="M1046,51.6521276 C1130.83045,29.328812 1279.08318,17.607883 1439,40.1656806 L1439,120 C1271.17211,77.9435312 1140.17211,55.1609071 1046,51.6521276 Z" id="Path-4" opacity="0.200000003"></path>
          </g>
          <g transform="translate(-4.000000, 76.000000)" fill="#FFFFFF" fill-rule="nonzero">
            <path
              d="M0.457,34.035 C57.086,53.198 98.208,65.809 123.822,71.865 C181.454,85.495 234.295,90.29 272.033,93.459 C311.355,96.759 396.635,95.801 461.025,91.663 C486.76,90.01 518.727,86.372 556.926,80.752 C595.747,74.596 622.372,70.008 636.799,66.991 C663.913,61.324 712.501,49.503 727.605,46.128 C780.47,34.317 818.839,22.532 856.324,15.904 C922.689,4.169 955.676,2.522 1011.185,0.432 C1060.705,1.477 1097.39,3.129 1121.236,5.387 C1161.703,9.219 1208.621,17.821 1235.4,22.304 C1285.855,30.748 1354.351,47.432 1440.886,72.354 L1441.191,104.352 L1.121,104.031 L0.457,34.035 Z"
            ></path>
          </g>
        </g>
      </svg>
    </div>
    <section id="tentang" class="bg-white border-b py-8 pt-20">
  <h2 class="w-full my-2 text-5xl font-bold leading-tight text-center text-gray-800">
    Tentang
  </h2>
  <div class="w-full mb-4">
    <div class="h-1 mx-auto gradient w-64 opacity-25 my-0 py-0 rounded-t"></div>
  </div>

  <div class="flex flex-wrap justify-center mt-10">
    <div class="w-11/12 md:w-4/5 lg:w-3/4 p-6">
    
      <p class="text-gray-600 text-justify leading-relaxed text-lg mb-6">
       <b>4IIAset</b> adalah sistem peminjaman aset berbasis web yang dikembangkan oleh siswa SMKN 4 Bandung untuk memudahkan proses pencatatan, persetujuan, dan pengembalian aset sekolah.
        Dengan adanya aplikasi ini, siswa maupun guru bisa melakukan berbagai hal penting yang sebelumnya dilakukan secara manual dan memakan banyak waktu.
      </p>

      <p class="text-gray-600 text-justify leading-relaxed text-lg mb-6">
        Melakukan request peminjaman aset dengan cepat tanpa harus datang langsung ke petugas.
        Mengetahui status peminjaman secara real-time, mulai dari pending, approved, rejected, hingga returned.
        Mengurangi risiko kehilangan, kerusakan, atau salah catat barang yang sering terjadi dalam proses manual.
        Membantu petugas dalam mengelola inventaris sekolah secara lebih efektif dan terstruktur.
      </p>

      <p class="text-gray-600 text-justify leading-relaxed text-lg">
        Aplikasi ini diharapkan dapat menjadi solusi digital untuk manajemen aset sekolah, sehingga proses peminjaman menjadi lebih transparan, efisien, dan akurat. 
        Selain itu, pengembangan aplikasi ini juga menjadi sarana pembelajaran nyata bagi siswa jurusan Informatika dalam mengimplementasikan ilmu yang telah dipelajari, khususnya dalam membangun sistem informasi berbasis teknologi yang bermanfaat bagi lingkungan sekolah.
      </p>
    </div>
  </div>
</section>

    <section id="Jurusan" class="bg-white border-b py-12">
  <div class="container mx-auto flex flex-wrap justify-center">
    <h2 class="w-full my-2 text-5xl font-bold leading-tight text-center text-gray-800">
      Jurusan
    </h2>
    <div class="w-full mb-12">
      <div class="h-1 mx-auto gradient w-64 opacity-25 my-0 py-0 rounded-t"></div>
    </div>

    <!-- Card Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 w-full px-6">
      
      <!-- RPL -->
      <div class="jurusan-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center text-center 
                  hover:scale-105 hover:shadow-2xl transition duration-300 ease-in-out">
        <i data-lucide="code" class="w-12 h-12 text-green-600 mb-4"></i>
        <h3 class="font-bold text-xl text-gray-800 mb-2">Rekayasa Perangkat Lunak (RPL)</h3>
        <p class="text-gray-600">Mempelajari pengembangan software, basis data, dan pemrograman modern.</p>
      </div>

      <!-- DKV -->
      <div class="jurusan-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center text-center 
                  hover:scale-105 hover:shadow-2xl transition duration-300 ease-in-out">
        <i data-lucide="palette" class="w-12 h-12 text-purple-600 mb-4"></i>
        <h3 class="font-bold text-xl text-gray-800 mb-2">Desain Komunikasi Visual (DKV)</h3>
        <p class="text-gray-600">Fokus pada desain grafis, multimedia, animasi, dan seni visual digital.</p>
      </div>

      <!-- TKJ -->
      <div class="jurusan-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center text-center 
                  hover:scale-105 hover:shadow-2xl transition duration-300 ease-in-out">
        <i data-lucide="server" class="w-12 h-12 text-red-600 mb-4"></i>
        <h3 class="font-bold text-xl text-gray-800 mb-2">Teknik Komputer Jaringan (TKJ)</h3>
        <p class="text-gray-600">Mempelajari jaringan komputer, server, dan infrastruktur IT.</p>
      </div>

      <!-- TOI -->
       <div class="jurusan-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center text-center 
                  hover:scale-105 hover:shadow-2xl transition duration-300 ease-in-out">
        <i data-lucide="settings" class="w-12 h-12 text-gray-600 mb-4"></i>
        <h3 class="font-bold text-xl text-gray-800 mb-2">Teknik Otomasi Industri (TOI)</h3>
        <p class="text-gray-600">Belajar sistem otomasi, PLC, dan teknologi industri modern.</p>
      </div>

      <!-- TITL -->
      <div class="jurusan-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center text-center 
                  hover:scale-105 hover:shadow-2xl transition duration-300 ease-in-out">
        <i data-lucide="zap" class="w-12 h-12 text-blue-600 mb-4"></i>
        <h3 class="font-bold text-xl text-gray-800 mb-2">Teknik Instalasi Tenaga Listrik (TITL)</h3>
        <p class="text-gray-600">Mendalami instalasi listrik, sistem kelistrikan, dan energi.</p>
      </div>

      <!-- TAV -->
      <div class="jurusan-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center text-center 
                  hover:scale-105 hover:shadow-2xl transition duration-300 ease-in-out">
        <i data-lucide="radio" class="w-12 h-12 text-yellow-600 mb-4"></i>
        <h3 class="font-bold text-xl text-gray-800 mb-2">Teknik Audio Video (TAV)</h3>
        <p class="text-gray-600">Mempelajari sistem audio, video, elektronika, dan broadcasting.</p>
      </div>

    </div>
  </div>
</section>

<!-- Tambahkan script Lucide -->
<script src="https://unpkg.com/lucide@latest"></script>
<script>
  lucide.createIcons();
</script>


    <!-- Change the colour #f8fafc to match the previous section colour -->
    <svg class="wave-top" viewBox="0 0 1439 147" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g transform="translate(-1.000000, -14.000000)" fill-rule="nonzero">
          <g class="wave" fill="#f8fafc">
            <path
              d="M1440,84 C1383.555,64.3 1342.555,51.3 1317,45 C1259.5,30.824 1206.707,25.526 1169,22 C1129.711,18.326 1044.426,18.475 980,22 C954.25,23.409 922.25,26.742 884,32 C845.122,37.787 818.455,42.121 804,45 C776.833,50.41 728.136,61.77 713,65 C660.023,76.309 621.544,87.729 584,94 C517.525,105.104 484.525,106.438 429,108 C379.49,106.484 342.823,104.484 319,102 C278.571,97.783 231.737,88.736 205,84 C154.629,75.076 86.296,57.743 0,32 L0,0 L1440,0 L1440,84 Z"
            ></path>
          </g>
          <g transform="translate(1.000000, 15.000000)" fill="#FFFFFF">
            <g transform="translate(719.500000, 68.500000) rotate(-180.000000) translate(-719.500000, -68.500000) ">
              <path d="M0,0 C90.7283404,0.927527913 147.912752,27.187927 291.910178,59.9119003 C387.908462,81.7278826 543.605069,89.334785 759,82.7326078 C469.336065,156.254352 216.336065,153.6679 0,74.9732496" opacity="0.100000001"></path>
              <path
                d="M100,104.708498 C277.413333,72.2345949 426.147877,52.5246657 546.203633,45.5787101 C666.259389,38.6327546 810.524845,41.7979068 979,55.0741668 C931.069965,56.122511 810.303266,74.8455141 616.699903,111.243176 C423.096539,147.640838 250.863238,145.462612 100,104.708498 Z"
                opacity="0.100000001"
              ></path>
              <path d="M1046,51.6521276 C1130.83045,29.328812 1279.08318,17.607883 1439,40.1656806 L1439,120 C1271.17211,77.9435312 1140.17211,55.1609071 1046,51.6521276 Z" opacity="0.200000003"></path>
            </g>
          </g>
        </g>
      </g>
    </svg>
 <section class="container mx-auto text-center py-16 bg-blue-600 text-white rounded-2xl shadow-lg">
  <h2 class="w-full my-2 text-4xl md:text-5xl font-bold leading-tight text-center">
    Siap Memulai?
  </h2>
  <div class="w-full mb-6">
    <div class="h-1 mx-auto bg-white w-1/6 opacity-25 my-0 py-0 rounded-t"></div>
  </div>
  <h3 class="my-4 text-xl md:text-2xl leading-relaxed">
    Kelola peminjaman aset sekolah dengan lebih cepat, mudah, dan efisien bersama <b>4IIAset</b>.
  </h3>
  <a href="{{ route('login') }}">
    <button class="mx-auto lg:mx-0 bg-white text-blue-600 font-bold rounded-full my-6 py-4 px-10 shadow-lg focus:outline-none focus:shadow-outline transform transition hover:scale-105 hover:bg-gray-100 duration-300 ease-in-out">
      Masuk Disini!
    </button>
  </a>
</section>

    <!--Footer-->
    <script>
      var scrollpos = window.scrollY;
      var header = document.getElementById("header");
      var navcontent = document.getElementById("nav-content");
      var navaction = document.getElementById("navAction");
      var brandname = document.getElementById("brandname");
      var toToggle = document.querySelectorAll(".toggleColour");

      document.addEventListener("scroll", function () {
        /*Apply classes for slide in bar*/
        scrollpos = window.scrollY;

        if (scrollpos > 10) {
          header.classList.add("bg-white");
          navaction.classList.remove("bg-white");
          navaction.classList.add("gradient");
          navaction.classList.remove("text-gray-800");
          navaction.classList.add("text-white");
          //Use to switch toggleColour colours
          for (var i = 0; i < toToggle.length; i++) {
            toToggle[i].classList.add("text-gray-800");
            toToggle[i].classList.remove("text-white");
          }
          header.classList.add("shadow");
          navcontent.classList.remove("bg-gray-100");
          navcontent.classList.add("bg-white");
        } else {
          header.classList.remove("bg-white");
          navaction.classList.remove("gradient");
          navaction.classList.add("bg-white");
          navaction.classList.remove("text-white");
          navaction.classList.add("text-gray-800");
          //Use to switch toggleColour colours
          for (var i = 0; i < toToggle.length; i++) {
            toToggle[i].classList.add("text-white");  
            toToggle[i].classList.remove("text-gray-800");
          }

          header.classList.remove("shadow");
          navcontent.classList.remove("bg-white");
          navcontent.classList.add("bg-gray-100");
        }
      });
    </script>
    <script>
      var navMenuDiv = document.getElementById("nav-content");
      var navMenu = document.getElementById("nav-toggle");

      document.onclick = check;
      function check(e) {
        var target = (e && e.target) || (event && event.srcElement);

        //Nav Menu
        if (!checkParent(target, navMenuDiv)) {
          // click NOT on the menu
          if (checkParent(target, navMenu)) {
            // click on the link
            if (navMenuDiv.classList.contains("hidden")) {
              navMenuDiv.classList.remove("hidden");
            } else {
              navMenuDiv.classList.add("hidden");
            }
          } else {
            // click both outside link and outside menu, hide menu
            navMenuDiv.classList.add("hidden");
          }
        }
      }
      function checkParent(t, elm) {
        while (t.parentNode) {
          if (t == elm) {
            return true;
          }
          t = t.parentNode; 
        }
        return false;
      }
    </script>  
    </script>

  </body>
</html>