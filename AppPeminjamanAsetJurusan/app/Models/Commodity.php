<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Commodity extends Model
{
    use HasFactory;
    
    protected $fillable = [
        'name', 'code', 'stock', 'jurusan', 'lokasi', 'condition', 'photo',
        'merk', 'sumber', 'tahun', 'deskripsi', 'harga_satuan'
    ];
    
    protected $appends = ['photo_url'];

    // Mutator to normalize jurusan on set
    public function setJurusanAttribute($value)
    {
        $this->attributes['jurusan'] = $value ? strtolower(trim($value)) : null;
    }

    // Accessor to normalize jurusan on get
    public function getJurusanAttribute($value)
    {
        return $value ? ucwords(strtolower(trim($value))) : null;
    }

    /**
     * Get the full URL for the commodity's photo.
     *
     * @return string|null
     */
    public function getPhotoUrlAttribute()
    {
        if ($this->photo) {
            $path = $this->photo;
            
            // If it's a full URL, return it
            if (filter_var($path, FILTER_VALIDATE_URL)) {
                return $path;
            }

            // Clean up common incorrect prefixes if they exist in DB
            $path = str_replace(['public/', '/storage/', 'storage/'], '', $path);
            $path = ltrim($path, '/');

            // Check existence in storage link
            if (file_exists(public_path('storage/' . $path))) {
                return asset('storage/' . $path);
            }
            
            // Fallback: prepend storage/ if not already there
            return asset('storage/' . $path);
        }
        return asset('images/default-asset.png');
    }

    // Relasi ke borrowings
    public function borrowings()
    {
        return $this->hasMany(Borrowing::class);
    }
}
