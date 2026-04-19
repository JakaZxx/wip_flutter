<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BorrowingItem extends Model
{
    use HasFactory;

    protected $appends = ['return_photo_url'];

    protected $fillable = [
        'borrowing_id',
        'commodity_id',
        'quantity',
        'status',
        'return_condition',
        'return_photo',
        'condition',
        'description',
        'photo_path',
    ];

    public function commodity()
    {
        return $this->belongsTo(Commodity::class);
    }

    public function borrowing()
    {
        return $this->belongsTo(Borrowing::class);
    }

    /**
     * Get the full URL for the return photo.
     *
     * @return string|null
     */
    public function getReturnPhotoUrlAttribute()
    {
        if ($this->return_photo) {
            $path = $this->return_photo;
            // Clean up common incorrect prefixes if they exist in DB
            $path = str_replace(['public/', '/storage/', 'storage/'], '', $path);
            $path = ltrim($path, '/');
            
            // Use standard storage path for Laravel web views
            return asset('storage/' . $path);
        }
        return null;
    }
}