<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Notifications\ResetPasswordNotification;
use App\Notifications\VerifyEmail;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'jurusan',
        'nis',
        'approval_status',
        'password_changed_at',
        'must_change_password',
        'profile_picture',
        'last_seen_notifications',
    ];

    // Mutator to normalize jurusan on set
    public function setJurusanAttribute($value)
    {
        $this->attributes['jurusan'] = $value ? strtolower(trim($value)) : null;
    }

    // Accessor to normalize jurusan on get
    public function getJurusanAttribute($value)
    {
        return $value ? strtolower(trim($value)) : null;
    }

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_seen_notifications' => 'datetime',
    ];

    protected $appends = ['profile_picture_url'];

    /**
     * Relasi ke tabel students
     */
    public function student()
    {
        return $this->hasOne(Student::class, 'user_id');
    }

    /**
     * Get full URL for profile picture or default image
     */
    public function getProfilePictureUrlAttribute()
    {
        if ($this->profile_picture && file_exists(public_path('storage/' . $this->profile_picture))) {
            return asset('storage/' . $this->profile_picture);
        }
        return asset('uploads/profile_pictures/default.png');
    }

    /**
     * Check if user is a student
     */
    public function isStudent(): bool
    {
        return strtolower($this->role) === 'students';
    }

    /**
     * Check if user is an officer
     */
    public function isOfficer(): bool
    {
        return strtolower($this->role) === 'officers';
    }

    /**
     * Check if user is an admin
     */
    public function isAdmin(): bool
    {
        return strtolower($this->role) === 'admin';
    }

    /**
     * Check if user is approved
     */
    public function isApproved(): bool
    {
        return $this->approval_status === 'approved';
    }

    /**
     * Check if user is pending approval
     */
    public function isPending(): bool
    {
        return $this->approval_status === 'pending';
    }

    /**
     * Check if user has changed password
     */
    public function hasChangedPassword(): bool
    {
        return !is_null($this->password_changed_at);
    }

    /**
     * Override sendPasswordResetNotification to use custom notification
     */
    public function sendPasswordResetNotification($token)
    {
        $this->notify(new ResetPasswordNotification($token));
    }

    /**
     * Override sendEmailVerificationNotification to use custom notification
     */
    public function sendEmailVerificationNotification()
    {
        $this->notify(new VerifyEmail);
    }

    /**
     * Get count of pending borrowings for the officer's jurusan since last seen
     */
    public function getPendingBorrowingsCount()
    {
        if (!$this->isOfficer()) {
            return 0;
        }

        $query = \App\Models\Borrowing::where('status', 'pending')
            ->whereHas('commodities', function($query) {
                $query->where('jurusan', $this->jurusan);
            });

        if ($this->last_seen_notifications) {
            $query->where('created_at', '>', $this->last_seen_notifications);
        }

        return $query->count();
    }

    /**
     * Get count of pending borrowings for admin since last seen
     */
    public function getPendingBorrowingsCountForAdmin()
    {
        if (!$this->isAdmin()) {
            return 0;
        }

        $query = \App\Models\Borrowing::where('status', 'pending');

        if ($this->last_seen_notifications) {
            $query->where('created_at', '>', $this->last_seen_notifications);
        }

        return $query->count();
    }

    /**
     * Get count of updated borrowings for student since last seen
     */
    public function getUpdatedBorrowingsCount()
    {
        if (!$this->isStudent() || !$this->student) {
            return 0;
        }

        $query = $this->student->borrowings()->where('updated_at', '>', $this->last_seen_notifications ?? now()->subDays(30));

        return $query->count();
    }
}
