<?php

namespace App\Models;

use App\Traits\ApiQuery;
use App\Traits\GlobalStatus;
use Illuminate\Database\Eloquent\Model;

class Region extends Model {
    use GlobalStatus, ApiQuery;

    public function plans() {
        return $this->hasMany(Plan::class);
    }

    public function getImageSrcAttribute() {
        if ($this->region_image) {
            return getImage(getFilePath('regionImage') . '/' . $this->region_image, getFileSize('regionImage'));
        }
        return null;
    }

    public function getBannerSrcAttribute() {
        if ($this->banner) {
            return getImage(getFilePath('regionBanner') . '/' . $this->banner, getFileSize('regionBanner'));
        }
        return null;
    }
}
