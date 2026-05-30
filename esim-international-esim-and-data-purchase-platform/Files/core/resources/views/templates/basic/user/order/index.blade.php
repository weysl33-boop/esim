@extends('Template::layouts.master')
@section('content')
    <h5 class="mb-3">{{ __($pageTitle) }}</h5>
    <div class="table--responsive mb-3">
        <table class="table table--custom table--responsive-sm">
            <thead>
                <tr>
                    <th>@lang('Order No.')</th>
                    <th class="text-center">@lang('Plan')</th>
                    <th class="text-center">@lang('Amount')</th>
                    <th class="text-center">@lang('Status')</th>
                    <th>@lang('Action')</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($orders as $order)
                    <tr>
                        <td>{{ $order->order_number }}</td>
                        <td class="text-center">{{ __($order->orderItem->plan->name) }} ({{ $order->orderItem->plan->readableDataVolume . ' - ' . $order->orderItem->plan->period . ' ' . __('days') }})</td>
                        <td class="text-center">{{ showAmount($order->total_amount) }}</td>
                        <td class="text-center"> @php echo $order->statusBadge @endphp</td>
                        <td>
                            <a href="{{ route('user.order.detail', $order->id) }}" class="btn btn--xsm btn-outline--base">
                                <i class="las la-desktop"></i>
                            </a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="100%">@lang('There is no order yet.')</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if ($orders->hasPages())
        <div class="pagination-wrapper">
            {{ paginateLinks($orders) }}
        </div>
    @endif
@endsection
