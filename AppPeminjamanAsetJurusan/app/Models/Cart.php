<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cart extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
    ];

    /**
     * Get the user that owns the cart.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the cart items for the cart.
     */
    public function items(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    /**
     * Get the cart for the current authenticated user, or create one if it doesn't exist.
     */
    public static function getOrCreateForUser($userId)
    {
        return static::firstOrCreate(
            ['user_id' => $userId],
            ['user_id' => $userId]
        );
    }

    /**
     * Add an item to the cart.
     */
    public function addItem($commodityId, $quantity = 1)
    {
        $cartItem = $this->items()->where('commodity_id', $commodityId)->first();

        if ($cartItem) {
            $cartItem->quantity += $quantity;
            $cartItem->save();
        } else {
            $this->items()->create([
                'commodity_id' => $commodityId,
                'quantity' => $quantity,
            ]);
        }

        return $this;
    }

    /**
     * Update the quantity of an item in the cart.
     */
    public function updateItemQuantity($commodityId, $quantity)
    {
        if ($quantity <= 0) {
            $this->removeItem($commodityId);
            return $this;
        }

        $cartItem = $this->items()->where('commodity_id', $commodityId)->first();

        if ($cartItem) {
            $cartItem->quantity = $quantity;
            $cartItem->save();
        } else {
            // Create the item if it doesn't exist
            $this->items()->create([
                'commodity_id' => $commodityId,
                'quantity' => $quantity,
            ]);
        }

        return $this;
    }

    /**
     * Remove an item from the cart.
     */
    public function removeItem($commodityId)
    {
        $this->items()->where('commodity_id', $commodityId)->delete();
        return $this;
    }

    /**
     * Clear all items from the cart.
     */
    public function clear()
    {
        $this->items()->delete();
        return $this;
    }

    /**
     * Get the total number of items in the cart.
     */
    public function getTotalItemsAttribute()
    {
        return $this->items->sum('quantity');
    }

    /**
     * Get the total number of different item types in the cart.
     */
    public function getTotalTypesAttribute()
    {
        return $this->items->count();
    }
}
