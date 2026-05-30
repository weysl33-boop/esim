<?php

namespace App\Models;

use App\Constants\Status;
use App\Traits\ApiQuery;
use App\Traits\GlobalStatus;
use Illuminate\Database\Eloquent\Model;

class Country extends Model {
    use GlobalStatus, ApiQuery;
    protected $guarded = [];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function plans() {
        return $this->belongsToMany(Plan::class);
    }

    public function scopeFeatured($query) {
        return $query->where('is_featured', Status::YES);
    }

    public function getImageSrcAttribute() {
        if ($this->image) {
            return getImage(getFilePath('countryFlag') . '/' . $this->image, getFileSize('countryFlag'));
        }
        return null;
    }

    public function getBannerSrcAttribute() {
        if ($this->banner) {
            return getImage(getFilePath('countryBanner') . '/' . $this->banner, getFileSize('countryBanner'));
        }
        return null;
    }
}
