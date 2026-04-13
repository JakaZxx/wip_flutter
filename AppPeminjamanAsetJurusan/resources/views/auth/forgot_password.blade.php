<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Lupa Password - 4llAset</title>

    <!-- Tailwind CSS -->
    <link href="https://unpkg.com/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet" />
    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />

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
        input:focus {
            outline: none !important;
            border-color: #007bff !important;
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.3);
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
    <section class="flex flex-col items-center justify-center flex-grow px-6 pt-24">
        <div class="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-md text-gray-800 animate-fade-in">
            <div class="flex flex-col items-center mb-6">
                <img src="{{ asset('ASSETS/smkn4.png') }}" alt="Logo" class="h-16 mb-2" />
                <h1 class="text-2xl font-bold tracking-wide text-blue-700">Lupa Password</h1>
                <p class="text-gray-500 text-sm mt-2">Masukkan email Anda untuk menerima link reset password</p>
            </div>

            @if(session('status'))
                <div class="bg-green-500 text-white text-sm px-4 py-2 rounded mb-4">
                    {{ session('status') }}
                </div>
            @endif

            @if($errors->any())
                <div class="bg-red-500 text-white text-sm px-4 py-2 rounded mb-4">
                    @foreach($errors->all() as $error)
                        {{ $error }}<br />
                    @endforeach
                </div>
            @endif

            <form method="POST" action="{{ route('password.forgot') }}" class="space-y-5">
                @csrf
                <div>
                    <label class="block text-sm font-semibold mb-1" for="email">Email</label>
                    <input
                        id="email"
                        type="email"
                        name="email"
                        value="{{ old('email') }}"
                        required
                        autocomplete="email"
                        autofocus
                        class="w-full px-4 py-3 rounded-lg border focus:ring-2 focus:ring-blue-400"
                    />
                </div>

                <button type="submit" class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold shadow-md transition transform hover:scale-105">
                    Kirim Link Reset Password
                </button>
            </form>

            <div class="text-center mt-4">
                <a href="{{ route('login') }}" class="text-blue-600 hover:text-blue-800 text-sm">Kembali ke Login</a>
            </div>
        </div>
    </section>

</body>
</html>
