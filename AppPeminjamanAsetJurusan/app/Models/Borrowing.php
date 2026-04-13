<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Borrowing extends Model
{
    use HasFactory;
    
    protected $appends = ['return_photo_url'];

    protected $fillable = [
        'student_id',
        'borrow_date',
        'borrow_time',
        'return_date',
        'return_time',
        'status',
        'tujuan',
        'return_condition',      // kondisi barang saat dikembalikan
        'return_photo',   // foto bukti barang
        'returned_by',    // ID pengguna yang melakukan pengembalian
    ];

    protected $casts = [
        'borrow_date' => 'datetime',
        'return_date' => 'datetime',
    ];

    // Relasi ke siswa
    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    // Relasi ke item yang dipinjam
    public function items()
    {
        return $this->hasMany(BorrowingItem::class);
    }

    // Relasi ke barang melalui item
    public function commodities()
    {
        return $this->belongsToMany(Commodity::class, 'borrowing_items')->withPivot('quantity');
    }

    // Relasi ke pengguna yang melakukan pengembalian
    public function returnedByUser()
    {
        return $this->belongsTo(User::class, 'returned_by');
    }

    // Accessor untuk menggabungkan borrow_date dan borrow_time
    public function getFullBorrowDatetimeAttribute()
    {
        if ($this->borrow_date && $this->borrow_time) {
            return $this->borrow_date->setTimeFromTimeString($this->borrow_time);
        }
        return $this->borrow_date; // Mengembalikan hanya tanggal jika waktu tidak ada
    }

    // Accessor untuk menggabungkan return_date dan return_time
    public function getFullReturnDatetimeAttribute()
    {
        if ($this->return_date && $this->return_time) {
            return $this->return_date->setTimeFromTimeString($this->return_time);
        }
        return $this->return_date; // Mengembalikan hanya tanggal jika waktu tidak ada
    }

    /**
     * Get the full URL for the return photo.
     *
     * @return string|null
     */
    public function getReturnPhotoUrlAttribute()
    {
        if ($this->return_photo) {
            return asset('storage/' . $this->return_photo);
        }
        return null;
    }
}
