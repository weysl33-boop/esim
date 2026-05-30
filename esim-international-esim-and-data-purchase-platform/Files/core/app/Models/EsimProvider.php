<?php

namespace App\Models;

use App\Traits\GlobalStatus;
use Illuminate\Database\Eloquent\Model;

class EsimProvider extends Model
{
    use GlobalStatus;

    protected $hidden = ['credentials'];

    protected $casts = [
        'credentials' => 'object'
    ];
}
