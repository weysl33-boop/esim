<?php

namespace App\Models;

use App\Traits\ApiQuery;
use App\Traits\GlobalStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Plan extends Model {
    use GlobalStatus, ApiQuery;

    protected $guarded = [];

    public function countries() {
        return $this->belongsToMany(Country::class);
    }

    public function region() {
        return $this->belongsTo(Region::class);
    }

    public function order() {
        return $this->hasMany(Order::class);
    }

    public function currency() {
        return $this->belongsTo(Currency::class);
    }

    public function campaign() {
        return $this->belongsTo(Campaign::class);
    }

    public function esimProvider() {
        return $this->belongsTo(EsimProvider::class);
    }

    public function convertedPrice(): Attribute {
        return Attribute::make(
            get: function () {
                if (!$this->currency_id) {
                    return $this->retail_price;
                }

                if ($this->currency && $this->currency->conversion_rate > 0) {
                    return $this->retail_price / $this->currency->conversion_rate;
                }

                return $this->retail_price;
            }
        );
    }

    public function readableDataVolume(): Attribute {
        return Attribute::get(function () {

            if ($this->data_volume < 0) {
                return __('Unlimited');
            }

            $precision = 2;
            $units = ['B', 'KB', 'MB', 'GB', 'TB'];

            $power = $this->data_volume > 0 ? floor(log($this->data_volume, 1024)) : 0;
            $power = min($power, count($units) - 1);

            $value = $this->data_volume / (1024 ** $power);
            return round($value, $precision) . ' ' . $units[$power];
        });
    }

    public function readableVoiceQuantity(): Attribute {
        return Attribute::get(function () {

            if ($this->voice_quantity == 0) {
                return '';
            }

            if ($this->voice_quantity < 0) {
                return __('Unlimited');
            }
            return getAmount($this->voice_quantity) . ' ' . __('minutes');
        });
    }

    public function readableSmsQuantity(): Attribute {
        return Attribute::get(function () {
            if ($this->sms_quantity == 0) {
                return '';
            }

            if ($this->sms_quantity < 0) {
                return __('Unlimited');
            }
            return $this->sms_quantity . ' ' . __('SMS');
        });
    }

    public function showPlanCapacities() {
        $capacities = [];

        if ($this->data_volume != 0) {
            if ($this->voice_quantity == 0 && $this->sms_quantity == 0) {
                $capacities[] = $this->readableDataVolume;
            } else {
                $capacities[] = $this->readableDataVolume . ' ' . __('Data');
            }
        }

        if ($this->voice_quantity != 0) {
            $capacities[] = ($this->voice_quantity > 0 ? $this->voice_quantity . ' ' . __('minutes') : __('Unlimited')) . ' ' . __('Talk Times');
        }

        if ($this->sms_quantity != 0) {
            $capacities[] = $this->sms_quantity > 0 ? $this->sms_quantity . ' ' . __('SMS') : __('Unlimited SMS');
        }

        return implode(' | ', $capacities);
    }

    // scope
    public function scopeGlobal($query) {
        return $query->where('area_coverage', 'global');
    }

    public function scopeLocal($query) {
        return $query->where('area_coverage', 'local');
    }

    public function scopeContinental($query) {
        return $query->where('area_coverage', 'continental');
    }

    public function discountAmount() {
        return $this->converted_price * $this->campaign?->discount / 100;
    }

    public function discountedPrice() {
        return $this->converted_price - ($this->converted_price * $this->campaign?->discount / 100);
    }
}
