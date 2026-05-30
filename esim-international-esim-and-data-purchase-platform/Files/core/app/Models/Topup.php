<?php

namespace App\Models;

use App\Constants\Status;
use App\Traits\ApiQuery;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Topup extends Model {
    use ApiQuery;
    protected $casts = [
        'info'   => 'object',
        'price'  => 'double'
    ];

    public function esim() {
        return $this->belongsTo(Esim::class);
    }

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function statusBadge(): Attribute {
        return new Attribute(function () {
            $html = '';
            if ($this->status == Status::TOPUP_COMPLETED) {
                $html = '<span class="badge badge--success">' . trans('Completed') . '</span>';
            } elseif ($this->status == Status::TOPUP_FAILED) {
                $html = '<i class="las la-info-circle me-1" data-bs-toggle="tooltip" data-bs-title="' . trans($this->failed_reason) . '"></i><span class="badge badge--danger">' . trans('Failed') . '</span>';
            } else {
                $html = '<span class="badge badge--dark">' . trans('Initiated') . '</span>';
            }

            return $html;
        });
    }
}
