<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Notifications\Notifiable;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Student extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $appends = ['profile_picture_url', 'role'];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_seen_notifications' => 'datetime',
    ];

    protected $fillable = [
        'name', 'email', 'password', 'role', 'jurusan', 'nis', 
        'approval_status', 'profile_picture', 'school_class_id', 'user_id'
    ];

    /**
     * Get full URL for profile picture or default image
     */
    public function getProfilePictureUrlAttribute()
    {
        if ($this->profile_picture) {
            $path = $this->profile_picture;
            if (filter_var($path, FILTER_VALIDATE_URL)) return $path;
            
            $path = str_replace(['public/', '/storage/', 'storage/', 'profiles/'], '', $path);
            $path = ltrim($path, '/');

            if (file_exists(public_path('storage/profiles/' . $path))) {
                return asset('storage/profiles/' . $path);
            }
            if (file_exists(public_path('storage/' . $path))) {
                return asset('storage/' . $path);
            }
            return url('/public-storage/profiles/' . $path);
        }
        return asset('uploads/profile_pictures/default.png');
    }

    // Relasi ke tabel school_classes
    public function schoolClass()
    {
        return $this->belongsTo(SchoolClass::class, 'school_class_id');
    }

    public function borrowings()
    {
        return $this->hasMany(Borrowing::class);
    }

    /**
     * Role checks for compatibility
     */
    public function isStudent(): bool { return true; }
    public function isAdmin(): bool { return false; }
    public function isOfficer(): bool { return false; }
    public function isApproved(): bool { return $this->approval_status === 'approved'; }
    public function isPending(): bool { return $this->approval_status === 'pending'; }

    // Accessor for role
    public function getRoleAttribute()
    {
        return 'students';
    }

    // Relasi ke tabel program_studies (sudah dihapus)
    // public function programStudy()
    // {
    //     return $this->belongsTo(ProgramStudy::class, 'program_id');
    // }

    // Relasi ke user
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi ke borrowings
    public function borrowings()
    {
        return $this->hasMany(Borrowing::class);
    }
}
