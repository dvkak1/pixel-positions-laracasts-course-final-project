<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Employer extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'logo',
        'user_id',
    ];

    public function jobs()
    {
        return $this->hasMany(Job::class);
    }
}
