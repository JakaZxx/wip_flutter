<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Verifikasi Email - 4llAset</title>

    <!-- Tailwind CSS -->
    <link href="https://unpkg.com/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet" />
    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <!-- Lottie -->
    <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>

    <style>
        body {
            font-family: 'Poppins', sans-serif;
        }
        .gradient-bg {
            background: linear-gradient(135deg, #007bff, #0056b3);
        }
        .animate-fade-in {
            animation: fadeIn 1s ease-in-out;
        }
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body class="gradient-bg min-h-screen flex flex-col">

    <!-- Navbar -->
    <nav class="w-full fixed top-0 z-50 bg-transparent py-4">
        <div class="container mx-auto flex items-center justify-between px-6">
            <a href="{{ url('/') }}" class="flex items-center gap-2 text-white font-bold text-2xl">
                <img src="{{ asset('ASSETS/smkn4.png') }}" alt="Logo" class="h-8 w-auto" />
                4llAset
            </a>
            <div class="flex gap-4">
                <a href="{{ url('/') }}" class="flex items-center text-white font-semibold py-2 px-5 rounded-lg transition transform duration-300 hover:scale-105 hover:bg-white hover:text-blue-600">
                    Home
                </a>
            </div>
        </div>
    </nav>

    <!-- Main Section -->
    <section class="flex flex-col lg:flex-row items-center justify-center flex-grow px-6 pt-24 lg:pt-0">
        <!-- Verification Form -->
        <div class="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-md text-gray-800 animate-fade-in">
            <div class="flex flex-col items-center mb-6">
                <img src="{{ asset('ASSETS/smkn4.png') }}" alt="Logo" class="h-16 mb-2" />
                <h1 class="text-2xl font-bold tracking-wide text-blue-700">Verifikasi Email</h1>
                <p class="text-gray-500 text-sm mt-2 text-center">Sebelum melanjutkan, silakan periksa email Anda untuk link verifikasi</p>
            </div>

            @if(session('success'))
                <div class="bg-green-500 text-white text-sm px-4 py-2 rounded mb-4">
                    {{ session('success') }}
                </div>
            @endif

            @if(session('resent'))
                <div class="bg-green-500 text-white text-sm px-4 py-2 rounded mb-4">
                    Link verifikasi telah dikirim ulang ke email Anda.
                </div>
            @endif

            @if($errors->any())
                <div class="bg-red-500 text-white text-sm px-4 py-2 rounded mb-4">
                    @foreach($errors->all() as $error)
                        {{ $error }}<br />
                    @endforeach
                </div>
            @endif

            <div class="space-y-4">
                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                    <div class="flex items-start">
                        <div class="flex-shrink-0">
                            <svg class="h-5 w-5 text-blue-400" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
                            </svg>
                        </div>
                        <div class="ml-3">
                            <p class="text-sm text-blue-700">
                                Jika Anda tidak menerima email, kami akan dengan senang hati mengirim ulang.
                            </p>
                        </div>
                    </div>
                </div>

                <form method="POST" action="{{ route('verification.send') }}" class="space-y-4">
                    @csrf
                    <button type="submit" class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold shadow-md transition transform hover:scale-105">
                        Kirim Ulang Link Verifikasi
                    </button>
                </form>

                <div class="text-center">
                    <form method="POST" action="{{ route('logout') }}" class="inline">
                        @csrf
                        <button type="submit" class="text-blue-600 hover:text-blue-800 text-sm underline">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Lottie Animation -->
        <div class="hidden lg:flex lg:w-1/2 justify-center items-center relative mt-10 lg:mt-0">
            <div class="absolute w-80 h-80 bg-white opacity-70 rounded-full blur-2xl transform -rotate-12"></div>
            <div class="absolute w-96 h-96 bg-white opacity-40 rounded-full top-10 left-20 blur-3xl"></div>

            <lottie-player
                src="https://assets4.lottiefiles.com/packages/lf20_0s6tfbuc.json"
                background="transparent"
                speed="1"
                style="width: 500px; height: 500px; position: relative; z-10;"
                loop
                autoplay>
            </lottie-player>
        </div>
    </section>

</body>
</html>
