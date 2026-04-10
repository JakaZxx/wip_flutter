@foreach($assets as $asset)
<div class="product-card fade-up">
    <div class="product-image">
        @if($asset->photo)
            <img src="{{ Str::startsWith($asset->photo, 'http') ? $asset->photo : url('storage/' . $asset->photo) }}" alt="{{ $asset->name }}">
        @else
            <i class="fas fa-box"></i>
        @endif
        <div class="product-stock {{ $asset->stock <= 5 ? 'low' : '' }}">
            Stok: {{ $asset->stock }}
        </div>
    </div>
    <div class="product-details">
        <div class="product-name">{{ $asset->name }}</div>
        <div class="product-meta">
            <span><i class="fas fa-barcode"></i> {{ $asset->code }}</span>
            <span><i class="fas fa-map-marker-alt"></i> {{ $asset->lokasi }}</span>
        </div>
    </div>
    <div class="product-actions">
        <div class="quantity-selector">
            <button type="button" class="quantity-btn" onclick="updateQuantity({{ $asset->id }}, -1, {{ $asset->stock }})">-</button>
            <input type="number" id="quantity-{{ $asset->id }}" name="items[{{ $asset->id }}]" 
                   class="quantity-input" value="{{ $cartQuantities[$asset->id] ?? 0 }}" 
                   min="0" max="{{ $asset->stock }}" readonly>
            <button type="button" class="quantity-btn" onclick="updateQuantity({{ $asset->id }}, 1, {{ $asset->stock }})">+</button>
        </div>
    </div>
</div>
@endforeach

@if($assets->isEmpty())
    <div style="grid-column: 1 / -1; text-align: center; padding: 50px; color: #6c757d;">
        <i class="fas fa-search" style="font-size: 48px; margin-bottom: 15px;"></i>
        <p>Tidak ada barang yang ditemukan.</p>
    </div>
@endif

<div id="pagination-links" style="grid-column: 1 / -1; margin-top: 20px;">
    {{ $assets->appends(request()->query())->links() }}
</div>
