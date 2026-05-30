<?php

namespace App\Models;

use App\Constants\Status;
use App\Traits\ApiQuery;
use App\Traits\GlobalStatus;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;

class Esim extends Model {
    use GlobalStatus, ApiQuery;

    protected $casts = ['info' => 'object'];

    public function orderItem() {
        return $this->belongsTo(OrderItem::class);
    }

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function scopeActive($query) {
        return $query->where('status', Status::ESIM_ACTIVE)->whereDate('expiry_date', '>=', now());
    }

    public function isReloadable() {
        return $this->status == Status::ESIM_ACTIVE
            && $this->orderItem->plan->reloadable
            && gs('topup_enabled');
    }

    public function isRefundable() {
        return $this->status == Status::ESIM_ACTIVE
            && $this->orderItem->plan->refundable
            && gs('refund_system_enabled');
    }

    public function scopeExpired($query) {
        return $query->whereDate('expiry_date', '<', now());
    }

    public function statusBadge(): Attribute {
        return new Attribute(function () {
            $html = '';
            if ($this->status == Status::ESIM_ACTIVE && $this->expiry_date < now()) {
                $html = '<span class="badge badge--danger">' . trans('Expired') . '</span>';
            } elseif ($this->status == Status::ESIM_ACTIVE) {
                $html = '<span class="badge badge--success">' . trans('Active') . '</span>';
            } elseif ($this->status == Status::ESIM_CANCELED) {
                $html = '<span class="badge badge--danger">' . trans('Canceled') . '</span>';
            } else {
                $html = '<span class="badge badge--warning">' . trans('Pending') . '</span>';
            }

            return $html;
        });
    }
}
