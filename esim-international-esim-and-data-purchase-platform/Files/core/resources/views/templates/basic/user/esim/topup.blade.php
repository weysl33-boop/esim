@extends('Template::layouts.master')
@section('content')
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <h5 class="mb-0">@lang('Select Topup Plans')</h5>
        <form action="{{ route('user.esim.topup.submit', $esim->id) }}" method="post" id="topupForm">
            @csrf
            <input type="hidden" name="uid">
            <button type="submit" class="btn btn--base btn--sm">@lang('Top Up Now')</button>
        </form>
    </div>

    <div class="topup-card-container">
        <div class="row gy-4">
            @foreach ($plans as $plan)
                <div class="col-sm-6 col-xl-4">
                    <label class="card custom--card topup-card h-100" for="plan-{{ $plan['uid'] }}">
                        <div class="card-body d-flex flex-column">
                            <input class="visually-hidden" form="topupForm" type="radio" name="uid" value="{{ $plan['uid'] }}" id="plan-{{ $plan['uid'] }}">
                            <span class="topup-card__input"></span>
                            <h5 class="card-title mb-3">{{ __($plan['name']) }}</h5>
                            <p class="card-text">@lang('Data'): {{ dataVolume($plan['data_volume'], isString: true) }}</p>

                            @if ($plan['voice_quantity'] > 0)
                                <p class="card-text">@lang('Voice'): {{ $plan['voice_quantity'] }} @lang('Minutes')</p>
                            @endif

                            @if ($plan['sms_quantity'] > 0)
                                <p class="card-text">@lang('SMS'): {{ $plan['sms_quantity'] }} @lang('Messages')</p>
                            @endif

                            <p class="card-text  mb-3">@lang('Validity'): {{ $plan['validity'] }} @lang('Days')</p>
                            <p class="mb-0 card-price">{{ showAmount($plan['price']) }} </p>
                        </div>
                    </label>
                </div>
            @endforeach
        </div>
    </div>
@endsection
