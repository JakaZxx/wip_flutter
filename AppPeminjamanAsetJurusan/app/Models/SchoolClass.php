<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SchoolClass extends Model
{
    use HasFactory;
    
    protected $fillable = [
        'name',
        'level',
        'program_study',
        'capacity',
        'description'
    ];

    // Relasi ke students
    public function students()
    {
        return $this->hasMany(Student::class, 'school_class_id');
    }
}
