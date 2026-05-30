<?php

namespace App\Http\Controllers\Admin;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Models\Esim;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class OrderController extends Controller {
    public function all($userId = null){
        $pageTitle = 'All Orders';
        $orders = $this->orderData(userId:$userId);
        return view('admin.order.index', compact('pageTitle', 'orders'));
    }

    public function pending($userId = null){
        $pageTitle = 'Pending Orders';
        $orders = $this->orderData('pending', $userId);
        return view('admin.order.index', compact('pageTitle', 'orders'));
    }

    public function completed($userId = null){
        $pageTitle = 'Completed Orders';
        $orders = $this->orderData('completed', $userId);
        return view('admin.order.index', compact('pageTitle', 'orders'));
    }

    protected function orderData($scope = null, $userId = null){
        if($scope){
            $query = Order::$scope();
        }else{
            $query = Order::query();
        }

        if($userId){
            $query->where('user_id', $userId);
        }

        return $query->searchable(['order_number', 'user:username'])->dateFilter()->orderBy('id', 'DESC')->paginate(getPaginate());
    }
}
