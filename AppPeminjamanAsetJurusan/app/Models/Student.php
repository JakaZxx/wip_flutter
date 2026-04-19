<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    use HasFactory;

    protected $appends = ['profile_picture_url', 'role'];

    protected $fillable = [
        'name', 'school_class_id', 'user_id'
    ];

    /**
     * Get full URL for profile picture or default image
     * Note: In unified logic, profile_picture usually comes from the User model,
     * but we keep this for compatibility if it's accessed via Student.
     */
    public function getProfilePictureUrlAttribute()
    {
        // Try to get from linked user if available
        if ($this->user && $this->user->profile_picture) {
            return $this->user->profile_picture_url;
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
    
    public function isApproved(): bool 
    { 
        return $this->user ? $this->user->approval_status === 'approved' : false; 
    }
    
    public function isPending(): bool 
    { 
        return $this->user ? $this->user->approval_status === 'pending' : false; 
    }

    // Accessor for role
    public function getRoleAttribute()
    {
        return 'students';
    }

    // Relasi ke user
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
