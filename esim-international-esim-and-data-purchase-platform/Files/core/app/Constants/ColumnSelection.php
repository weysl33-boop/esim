<?php

namespace App\Constants;

class ColumnSelection {
    const ESIM_MODEL = [
        'id',
        'order_item_id',
        'serial_number',
        'iccid',
        'phone_number',
        'qr_code',
        'qr_code_image',
        'expiry_date',
        'status',
        'created_at'
    ];

    const TOPUP_MODEL = [
        'id',
        'esim_id',
        'name',
        'data_volume',
        'voice_quantity',
        'sms_quantity',
        'validity',
        'price',
        'status',
        'created_at'
    ];
}
