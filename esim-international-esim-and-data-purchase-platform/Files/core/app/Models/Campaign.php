<?php

namespace App\Models;

use App\Traits\GlobalStatus;
use Illuminate\Database\Eloquent\Model;

class Campaign extends Model {
    use GlobalStatus;

    protected $casts = [
        'seo_content' => 'object'
    ];

    public function plans() {
        return $this->hasMany(Plan::class);
    }
}
