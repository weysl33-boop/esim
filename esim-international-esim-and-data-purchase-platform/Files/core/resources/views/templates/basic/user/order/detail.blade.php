@extends('Template::layouts.master')
@section('content')
    <div class="mb-3 flex-between">
        <h5 class="mb-0">{{ __($pageTitle) }}</h5>
    </div>
    <div class="table-responsive mb-4">
        <table class="table table--custom">
            <thead>
                <tr>
                    <th>@lang('Plan')</th>
                    <th>@lang('Quantity')</th>
                    <th>@lang('eSIM Created')</th>
                    <th>@lang('Price')</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <div>
                            <strong>{{ $order->orderItem->plan->name }}</strong>
                        </div>
                    </td>
                    <td>1</td>
                    <td>
                        @if ($order->orderItem->is_esim_created)
                            <span class="badge badge--success">@lang('Yes')</span>
                            <a href="{{ route('user.esim.detail', $order->orderItem->esim->id) }}" class="text--base text-decoration-underline ms-2">@lang('View eSIM')</a>
                        @else
                            <span class="badge badge--danger">@lang('No')</span>
                        @endif
                    </td>
                    <td>{{ showAmount($order->orderItem->price) }}</td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="row gy-4">
        <div class="col-md-6">
            <div class="details-card style-two">
                <p class="details-card__title">@lang('Order Information')</p>
                <div class="details-card__body">
                    <ul class="details-card__list">
                        <li class="details-card__item">
                            <span class="label">@lang('Order Number')</span>
                            <span class="value">{{ $order->order_number }}</span>
                        </li>
                        <li class="details-card__item">
                            <span class="label">@lang('Amount')</span>
                            <span class="value">{{ showAmount($order->total_amount) }}</span>
                        </li>
                        <li class="details-card__item">
                            <span class="label">@lang('Status')</span>
                            <span class="value">{!! $order->statusBadge !!}</span>
                        </li>
                        <li class="details-card__item">
                            <span class="label">@lang('Ordered At')</span>
                            <span class="value">{{ showDateTime($order->created_at, 'd M, Y H:i A') }}</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="details-card style-two">
                <p class="details-card__title">@lang('Payment Information')</p>
                <div class="details-card__body">
                    <ul class="details-card__list">
                        @if ($order->deposit)
                            <li class="details-card__item">
                                <span class="label">@lang('Payment Method')</span>
                                <span class="value">{{ $order->deposit->methodName() }}</span>
                            </li>
                            <li class="details-card__item">
                                <span class="label">@lang('Transaction Number')</span>
                                <span class="value">{{ $order->deposit->trx }}</span>
                            </li>
                            <li class="details-card__item">
                                <span class="label">@lang('Amount')</span>
                                <span class="value">{{ showAmount($order->deposit->amount) }}</span>
                            </li>
                            <li class="details-card__item">
                                <span class="label">@lang('Gateway Charge')</span>
                                <span class="value">{{ showAmount($order->deposit->charge) }}</span>
                            </li>
                            <li class="details-card__item total">
                                <span class="label">@lang('Payable')</span>
                                <span class="value">{{ showAmount($order->deposit->final_amount) }}</span>
                            </li>
                        @else
                            <li class="details-card__item">
                                <span class="label">@lang('Payment Method')</span>
                                <span class="value">@lang('Wallet Balance')</span>
                            </li>
                            <li class="details-card__item">
                                <span class="label">@lang('Subtotal')</span>
                                <span class="value">{{ showAmount($order->total_amount) }}</span>
                            </li>
                            <li class="details-card__item total">
                                <span class="label">@lang('Payable')</span>
                                <span class="value">{{ showAmount($order->total_amount) }}</span>
                            </li>
                        @endif
                    </ul>
                </div>
            </div>
        </div>
    </div>
@endsection
