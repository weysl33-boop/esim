<?php

namespace App\Models;

use App\Constants\Status;
use App\Traits\ApiQuery;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;

class Order extends Model {
    use ApiQuery;

    protected $casts = [
        'total_amount' => 'double',
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function plan() {
        return $this->belongsTo(Plan::class);
    }

    public function deposit() {
        return $this->hasOne(Deposit::class);
    }

    public function orderItem() {
        return $this->hasOne(OrderItem::class);
    }

    public function scopeInitiated($query) {
        return $query->where('status', Status::ORDER_INITIATE);
    }

    public function scopePending($query) {
        return $query->where('status', Status::ORDER_PENDING);
    }

    public function scopeCompleted($query) {
        return $query->where('status', Status::ORDER_COMPLETED);
    }

    public function statusBadge(): Attribute {
        return new Attribute(function () {
            $html = '';
            if ($this->status == Status::ORDER_COMPLETED) {
                $html = '<span class="badge badge--success">' . trans('Completed') . '</span>';
            } else if ($this->status == Status::ORDER_PENDING) {
                $html = '<span class="badge badge--warning">' . trans('Pending') . '</span>';
            } else {
                $html = '<span class="badge badge--dark">' . trans('Initiated') . '</span>';
            }
            return $html;
        });
    }
}
