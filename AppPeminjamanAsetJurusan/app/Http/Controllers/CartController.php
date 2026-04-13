<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Commodity;

class CartController extends Controller
{
    /**
     * Get or create cart for the current user.
     */
    protected function getCartForUser()
    {
        return Cart::getOrCreateForUser(auth()->id());
    }

    /**
     * Add item to cart.
     */
    public function addItem(Request $request)
    {
        $request->validate([
            'commodity_id' => 'required|exists:commodities,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $cart = $this->getCartForUser();
        $commodity = Commodity::findOrFail($request->commodity_id);

        // Check if stock is available
        if ($commodity->stock == 0 && $request->quantity > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Maaf Stock tidak tersedia'
            ]);
        } elseif ($request->quantity > $commodity->stock) {
            return response()->json([
                'success' => false,
                'message' => "Stok tidak mencukupi. Maksimal: {$commodity->stock}"
            ]);
        }

        $cart->addItem($request->commodity_id, $request->quantity);

        return response()->json([
            'success' => true,
            'message' => 'Barang berhasil ditambahkan ke keranjang',
            'cart' => $this->getCartSummary()
        ]);
    }

    /**
     * Update item quantity in cart.
     */
    public function updateItem(Request $request)
    {
        try {
            $request->validate([
                'commodity_id' => 'required|exists:commodities,id',
                'quantity' => 'required|integer|min:0',
            ]);

            $cart = $this->getCartForUser();
            $commodity = Commodity::findOrFail($request->commodity_id);

            // Check if stock is available
            if ($commodity->stock == 0 && $request->quantity > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Maaf Stock tidak tersedia'
                ]);
            } elseif ($request->quantity > $commodity->stock) {
                return response()->json([
                    'success' => false,
                    'message' => "Stok tidak mencukupi. Maksimal: {$commodity->stock}"
                ]);
            }

            $cart->updateItemQuantity($request->commodity_id, $request->quantity);

            return response()->json([
                'success' => true,
                'message' => 'Jumlah barang berhasil diupdate',
                'cart' => $this->getCartSummary()
            ]);
        } catch (\Exception $e) {
            \Log::error('CartController@updateItem error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat mengupdate keranjang. Silakan coba lagi.'
            ]);
        }
    }

    /**
     * Remove item from cart.
     */
    public function removeItem(Request $request)
    {
        $request->validate([
            'commodity_id' => 'required|exists:commodities,id',
        ]);

        $cart = $this->getCartForUser();
        $cart->removeItem($request->commodity_id);

        return response()->json([
            'success' => true,
            'message' => 'Barang berhasil dihapus dari keranjang',
            'cart' => $this->getCartSummary()
        ]);
    }

    /**
     * Clear all items from cart.
     */
    public function clear()
    {
        $cart = $this->getCartForUser();
        $cart->clear();

        return response()->json([
            'success' => true,
            'message' => 'Keranjang berhasil dikosongkan',
            'cart' => $this->getCartSummary()
        ]);
    }

    /**
     * Get cart summary for display.
     */
    protected function getCartSummary()
    {
        $cart = $this->getCartForUser();
        $cart->load('items.commodity');

        return [
            'total_items' => $cart->total_items,
            'total_types' => $cart->total_types,
            'items' => $cart->items->map(function ($item) {
                return [
                    'id' => $item->commodity->id,
                    'name' => $item->commodity->name,
                    'code' => $item->commodity->code,
                    'photo' => $item->commodity->photo,
                    'quantity' => $item->quantity,
                    'stock' => $item->commodity->stock,
                ];
            })
        ];
    }

    /**
     * Get cart items for borrowing request.
     */
    public function getItemsForBorrowing()
    {
        $cart = $this->getCartForUser();
        $cart->load('items.commodity');

        return $cart->items->mapWithKeys(function ($item) {
            return [$item->commodity->id => $item->quantity];
        })->toArray();
    }

    /**
     * Display cart index page.
     */
    public function index()
    {
        $cart = $this->getCartForUser();
        $cart->load('items.commodity');

        return view('cart.index', compact('cart'));
    }

    /**
     * Display cart checkout page.
     */
    public function checkout()
    {
        $cart = $this->getCartForUser();
        $cart->load('items.commodity');

        if ($cart->items->isEmpty()) {
            return redirect()->route('cart.index')
                ->with('error', 'Keranjang Anda kosong. Silakan tambahkan barang terlebih dahulu.');
        }

        return view('cart.checkout', compact('cart'));
    }
}
