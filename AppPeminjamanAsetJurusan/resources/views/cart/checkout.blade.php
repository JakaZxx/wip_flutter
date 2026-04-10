@extends('layouts.app')

@section('title', 'Checkout Keranjang - 4LLAset')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="max-w-4xl mx-auto">
        <div class="flex items-center justify-between mb-6">
            <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
                <i class="bx bx-check-circle text-green-600 mr-2"></i>
                Checkout Keranjang
            </h1>
            <a href="{{ route('cart.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition duration-200">
                <i class="bx bx-arrow-back mr-2"></i>
                Kembali ke Keranjang
            </a>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <!-- Cart Items Review -->
            <div>
                <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        <i class="bx bx-list-ul mr-2"></i>
                        Barang yang Akan Dipinjam
                    </h3>

                    <div id="checkout-items">
                        <div class="text-center py-8">
                            <i class="bx bx-loader-alt bx-spin text-4xl text-gray-400 mb-4"></i>
                            <p class="text-gray-600 dark:text-gray-400">Memuat barang...</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Borrowing Request Form -->
            <div>
                <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        <i class="bx bx-edit mr-2"></i>
                        Formulir Peminjaman
                    </h3>

                    @if($errors->any())
                        <div class="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded">
                            <ul class="list-disc list-inside">
                                @foreach($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif

                    @if(session('error'))
                        <div class="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded">
                            {{ session('error') }}
                        </div>
                    @endif

                    <form id="borrowing-form" action="{{ route('borrowing.request.store.student') }}" method="POST">
                        @csrf

                        <div class="mb-4">
                            <label for="tujuan" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                Tujuan Peminjaman <span class="text-red-500">*</span>
                            </label>
                            <textarea
                                id="tujuan"
                                name="tujuan"
                                rows="3"
                                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                                placeholder="Jelaskan tujuan peminjaman barang-barang ini..."
                                required
                            >{{ old('tujuan') }}</textarea>
                            @error('tujuan')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <div class="mb-4">
                            <label for="borrow_date" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                Tanggal Mulai <span class="text-red-500">*</span>
                            </label>
                            <input
                                type="date"
                                id="borrow_date"
                                name="borrow_date"
                                value="{{ old('borrow_date') }}"
                                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                                min="{{ date('Y-m-d') }}"
                                required
                            >
                            @error('borrow_date')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <div class="mb-4">
                            <label for="return_date" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                Tanggal Selesai <span class="text-red-500">*</span>
                            </label>
                            <input
                                type="date"
                                id="return_date"
                                name="return_date"
                                value="{{ old('return_date') }}"
                                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                                min="{{ date('Y-m-d', strtotime('+1 day')) }}"
                                required
                            >
                            @error('return_date')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <div class="mb-4">
                            <label for="return_time" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                Waktu Selesai (Opsional)
                            </label>
                            <input
                                type="time"
                                id="return_time"
                                name="return_time"
                                value="{{ old('return_time') }}"
                                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                            >
                            @error('return_time')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <!-- Hidden fields for cart items -->
                        <div id="cart-items-data"></div>

                        <div class="mt-6">
                            <button
                                type="submit"
                                id="submit-borrowing"
                                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-md transition duration-200"
                            >
                                <i class="bx bx-send mr-2"></i>
                                Ajukan Peminjaman
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    loadCheckoutItems();

    // Set minimum date for end date when start date changes
    document.getElementById('borrow_date').addEventListener('change', function() {
        const startDate = this.value;
        const endDateInput = document.getElementById('return_date');
        if (startDate) {
            endDateInput.min = startDate;
            if (endDateInput.value && endDateInput.value <= startDate) {
                endDateInput.value = '';
            }
        }
    });


});

function loadCheckoutItems() {
    fetch('{{ route("cart.summary") }}', {
        method: 'GET',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Accept': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        displayCheckoutItems(data);
    })
    .catch(error => {
        console.error('Error loading checkout items:', error);
        document.getElementById('checkout-items').innerHTML = `
            <div class="text-center py-8">
                <i class="bx bx-error text-4xl text-red-400 mb-4"></i>
                <p class="text-red-600 dark:text-red-400">Gagal memuat barang</p>
                <button onclick="loadCheckoutItems()" class="mt-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                    Coba Lagi
                </button>
            </div>
        `;
    });
}

function displayCheckoutItems(cartData) {
    const checkoutItems = document.getElementById('checkout-items');

    if (!cartData.items || cartData.items.length === 0) {
        checkoutItems.innerHTML = `
            <div class="text-center py-8">
                <i class="bx bx-cart text-6xl text-gray-300 mb-4"></i>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Keranjang Kosong</h3>
                <p class="text-gray-600 dark:text-gray-400 mb-4">Tidak ada barang di keranjang</p>
                <a href="{{ route('cart.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg">
                    <i class="bx bx-arrow-back mr-2"></i>
                    Kembali ke Keranjang
                </a>
            </div>
        `;
        return;
    }

    let itemsHtml = '<div class="space-y-3">';
    cartData.items.forEach(item => {
        itemsHtml += `
            <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <div class="flex items-center space-x-3">
                    <img src="${item.photo ? '/storage/' + item.photo : '/ASSETS/boxes.png'}"
                         alt="${item.name}"
                         class="w-12 h-12 object-cover rounded">
                    <div>
                        <h4 class="font-medium text-gray-900 dark:text-white">${item.name}</h4>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Kode: ${item.code}</p>
                    </div>
                </div>
                <div class="text-right">
                    <p class="font-semibold text-gray-900 dark:text-white">Jumlah: ${item.quantity}</p>
                    <p class="text-sm text-gray-600 dark:text-gray-400">Stok: ${item.stock}</p>
                </div>
            </div>
        `;
    });
    itemsHtml += '</div>';

    // Add summary
    itemsHtml += `
        <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-600">
            <div class="flex justify-between text-sm">
                <span class="text-gray-600 dark:text-gray-400">Total Jenis Barang:</span>
                <span class="font-semibold">${cartData.total_types}</span>
            </div>
            <div class="flex justify-between text-sm">
                <span class="text-gray-600 dark:text-gray-400">Total Item:</span>
                <span class="font-semibold">${cartData.total_items}</span>
            </div>
        </div>
    `;

    checkoutItems.innerHTML = itemsHtml;
}
</script>
@endsection
