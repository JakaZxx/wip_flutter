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
            $photoPath = $this->photo;

            // Remove common incorrect prefixes
            $photoPath = str_replace('laptop /', '', $photoPath);
            $photoPath = str_replace('/storage/', '', $photoPath);
            $photoPath = str_replace('public/', '', $photoPath);

            // Trim any leading/trailing slashes that might result from replacements
            $photoPath = ltrim($photoPath, '/');

            return asset('storage/' . $photoPath);
        }
        return null;
    }

    // Relasi ke borrowings
    public function borrowings()
    {
        return $this->hasMany(Borrowing::class);
    }
}
