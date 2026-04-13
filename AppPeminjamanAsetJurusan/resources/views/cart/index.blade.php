@extends('layouts.app')

@section('title', 'Keranjang Peminjaman - 4LLAset')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="max-w-4xl mx-auto">
        <div class="flex items-center justify-between mb-6">
            <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
                <i class="bx bx-cart text-blue-600 mr-2"></i>
                Keranjang Peminjaman
            </h1>
            <a href="{{ route('students.assets.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition duration-200">
                <i class="bx bx-plus mr-2"></i>
                Tambah Barang
            </a>
        </div>

        @if($cart->items->isEmpty())
            <div class="text-center py-12">
                <i class="bx bx-cart text-8xl text-gray-300 mb-4"></i>
                <h3 class="text-2xl font-semibold text-gray-900 dark:text-white mb-2">Keranjang Kosong</h3>
                <p class="text-gray-600 dark:text-gray-400 mb-6">Belum ada barang di keranjang Anda</p>
                <a href="{{ route('students.assets.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg">
                    <i class="bx bx-plus mr-2"></i>
                    Mulai Tambah Barang
                </a>
            </div>
        @else
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md">
                <div class="p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                            Barang di Keranjang ({{ $cart->total_types }} jenis, {{ $cart->total_items }} item)
                        </h3>
                        <button onclick="clearCart()" class="text-red-600 hover:text-red-800 text-sm">
                            <i class="bx bx-trash mr-1"></i>
                            Kosongkan Keranjang
                        </button>
                    </div>

                    <div id="cart-items-list" class="space-y-4">
                        @include('cart._items', ['cart' => $cart])
                    </div>

                    <div class="mt-6 pt-6 border-t border-gray-200 dark:border-gray-600">
                        <div class="flex justify-between items-center">
                            <div>
                                <p class="text-sm text-gray-600 dark:text-gray-400">Total Jenis Barang: <span class="font-semibold">{{ $cart->total_types }}</span></p>
                                <p class="text-sm text-gray-600 dark:text-gray-400">Total Item: <span class="font-semibold">{{ $cart->total_items }}</span></p>
                            </div>
                            <a href="{{ route('cart.checkout') }}"
                               class="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg">
                                <i class="bx bx-check-circle mr-2"></i>
                                Lanjut ke Checkout
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        @endif
    </div>
</div>

<script>
function updateQuantity(commodityId, newQuantity) {
    if (newQuantity <= 0) {
        removeItem(commodityId);
        return;
    }

    fetch('{{ route("cart.update") }}', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({
            commodity_id: commodityId,
            quantity: newQuantity
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert(data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Gagal mengupdate jumlah barang');
    });
}

function removeItem(commodityId) {
    if (!confirm('Apakah Anda yakin ingin menghapus barang ini dari keranjang?')) {
        return;
    }

    fetch('{{ route("cart.remove") }}', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({
            commodity_id: commodityId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert(data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Gagal menghapus barang');
    });
}

function clearCart() {
    if (!confirm('Apakah Anda yakin ingin mengosongkan seluruh keranjang?')) {
        return;
    }

    fetch('{{ route("cart.clear") }}', {
        method: 'POST',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert(data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Gagal mengosongkan keranjang');
    });
}
</script>
@endsection

@section('scripts')
<script>
    function updateQuantity(commodityId, newQuantity) {
        if (newQuantity <= 0) {
            removeItem(commodityId);
            return;
        }

        fetch('{{ route("cart.update") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({
                commodity_id: commodityId,
                quantity: newQuantity
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Instead of location.reload(), fetch new data
                fetchCartData();
            } else {
                alert(data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Gagal mengupdate jumlah barang');
        });
    }

    function removeItem(commodityId) {
        if (!confirm('Apakah Anda yakin ingin menghapus barang ini dari keranjang?')) {
            return;
        }

        fetch('{{ route("cart.remove") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({
                commodity_id: commodityId
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Instead of location.reload(), fetch new data
                fetchCartData();
            } else {
                alert(data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Gagal menghapus barang');
        });
    }

    function clearCart() {
        if (!confirm('Apakah Anda yakin ingin mengosongkan seluruh keranjang?')) {
            return;
        }

        fetch('{{ route("cart.clear") }}', {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Instead of location.reload(), fetch new data
                fetchCartData();
            } else {
                alert(data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Gagal mengosongkan keranjang');
        });
    }

    function initializeCartPage() {
        // Re-attach event listeners for quantity buttons and remove buttons if needed
        // Since these are inline onclick, they should work after content replacement.
        // However, if there were dynamic event listeners, they would need re-attaching here.
    }

    const cartItemsList = document.getElementById('cart-items-list');

    function fetchCartData() {
        const url = `{{ route('cart.data') }}`;

        fetch(url)
            .then(response => response.text())
            .then(html => {
                cartItemsList.innerHTML = html;
                initializeCartPage(); // Re-initialize JS after content update
            })
            .catch(error => console.error('Error fetching cart data:', error));
    }

    document.addEventListener('DOMContentLoaded', function () {
        initializeCartPage(); // Initial call to set up page elements
        setInterval(fetchCartData, 5000); // Poll every 5 seconds
    });
</script>
@endsection
