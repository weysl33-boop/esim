@extends('Template::layouts.frontend')
@section('content')
    <section class="my-120">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <form action="{{ route('user.order.payment.initiate') }}" method="post" class="deposit-form">
                        @csrf
                        <input type="hidden" name="currency">
                        <input type="hidden" name="order_id" value="{{ $order->id }}">

                        <div class="row justify-content-center gy-sm-4 gy-3">
                            <div class="col-lg-6">
                                <div class="payment-system-list is-scrollable gateway-option-list">
                                    <label for="main-balance" class="payment-item gateway-option">
                                        <div class="payment-item__info">
                                            <span class="payment-item__check"></span>
                                            <span class="payment-item__name">@lang('eSIM Wallet')
                                                ({{ showAmount(auth()->user()->balance) }})</span>
                                        </div>
                                        <div class="payment-item__thumb">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-wallet-icon lucide-wallet"><path d="M19 7V4a1 1 0 0 0-1-1H5a2 2 0 0 0 0 4h15a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1"/><path d="M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4"/></svg>
                                        </div>
                                        <input class="payment-item__radio gateway-input" id="main-balance" hidden type="radio" name="gateway" value="main-balance" @checked(old('gateway') == 'main-balance')>
                                    </label>
                                    @foreach ($gatewayCurrency as $data)
                                        <label for="{{ titleToKey($data->name) }}" class="payment-item @if ($loop->index > 7) d-none @endif gateway-option">
                                            <div class="payment-item__info">
                                                <span class="payment-item__check"></span>
                                                <span class="payment-item__name">{{ __($data->name) }}</span>
                                            </div>
                                            <div class="payment-item__thumb">
                                                <img class="payment-item__thumb-img" src="{{ getImage(getFilePath('gateway') . '/' . $data->method->image) }}" alt="@lang('payment-thumb')">
                                            </div>
                                            <input class="payment-item__radio gateway-input" id="{{ titleToKey($data->name) }}" hidden data-gateway="{{ json_encode($data) }}" type="radio" name="gateway" value="{{ $data->method_code }}" @checked(old('gateway', $loop->first) == $data->method_code) data-min-amount="{{ showAmount($data->min_amount) }}" data-max-amount="{{ showAmount($data->max_amount) }}">
                                        </label>
                                    @endforeach
                                    @if ($gatewayCurrency->count() > 4)
                                        <button type="button" class="payment-item__btn more-gateway-option">
                                            <p class="payment-item__btn-text">@lang('Show All Payment Options')</p>
                                            <span class="payment-item__btn__icon"><i class="fas fa-chevron-down"></i></span>
                                        </button>
                                    @endif
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="payment-system-list p-3 mb-3">
                                    <h5 class="mb-3">@lang('Plan Information')</h5>
                                    <div class="deposit-info">
                                        <div class="deposit-info__title">
                                            <p class="text mb-0">@lang('Plan')</p>
                                        </div>
                                        <div class="deposit-info__input">
                                            {{ __($order->orderItem->plan->name) }}
                                        </div>
                                    </div>
                                    <div class="deposit-info">
                                        <div class="deposit-info__title">
                                            <p class="text mb-0">@lang('Data')</p>
                                        </div>
                                        <div class="deposit-info__input">
                                            {{ $order->orderItem->plan->readableDataVolume }}
                                        </div>
                                    </div>
                                    @if ($order->orderItem->plan->voice_quantity != 0)
                                        <div class="deposit-info">
                                            <div class="deposit-info__title">
                                                <p class="text mb-0">@lang('Talk Times')</p>
                                            </div>
                                            <div class="deposit-info__input">
                                                {{ $order->orderItem->plan->readableVoiceQuantity }}
                                            </div>
                                        </div>
                                    @endif
                                    @if ($order->orderItem->plan->sms_quantity != 0)
                                        <div class="deposit-info">
                                            <div class="deposit-info__title">
                                                <p class="text mb-0">@lang('SMS')</p>
                                            </div>
                                            <div class="deposit-info__input">
                                                {{ $order->orderItem->plan->readableSmsQuantity }}
                                            </div>
                                        </div>
                                    @endif
                                    <div class="deposit-info">
                                        <div class="deposit-info__title">
                                            <p class="text mb-0">@lang('Price')</p>
                                        </div>
                                        <div class="deposit-info__input">
                                            {{ showAmount($order->orderItem->price) }}
                                        </div>
                                    </div>
                                </div>
                                <div class="payment-system-list p-3">
                                    <div class="deposit-info">
                                        <div class="deposit-info__title">
                                            <p class="text mb-0">@lang('Subtotal')</p>
                                        </div>
                                        <div class="deposit-info__input">
                                            {{ showAmount($order->total_amount) }}
                                        </div>
                                    </div>
                                    <div class="deposit-info">
                                        <div class="deposit-info__title">
                                            <p class="text has-icon">@lang('Processing Charge')
                                                <span data-bs-toggle="tooltip" title="@lang('Processing charge for payment gateways')" class="proccessing-fee-info"><i class="las la-info-circle"></i></span>
                                            </p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p><span class="processing-fee">@lang('0.00')</span>
                                                {{ __(gs('cur_text')) }}</p>
                                        </div>
                                    </div>
                                    <div class="deposit-info total-amount pt-3">
                                        <div class="deposit-info__title">
                                            <p class="text">@lang('Total')</p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p><span class="final-amount">@lang('0.00')</span>
                                                {{ __(gs('cur_text')) }}</p>
                                        </div>
                                    </div>
                                    <div class="deposit-info gateway-conversion d-none total-amount pt-2">
                                        <div class="deposit-info__title">
                                            <p class="text">@lang('Conversion')</p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p class="conversion-text"></p>
                                        </div>
                                    </div>
                                    <div class="deposit-info conversion-currency d-none total-amount pt-2">
                                        <div class="deposit-info__title">
                                            <p>@lang('In') <span class="gateway-currency"></span></p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p><span class="in-currency"></span></p>
                                        </div>
                                    </div>
                                    <div class="d-none crypto-message mb-3">
                                        @lang('Conversion with') <span class="gateway-currency"></span> @lang('and final value will Show on next step')
                                    </div>
                                    <button type="submit" class="btn btn--base w-100">@lang('Confirm Payment')</button>
                                    <div class="info-text pt-3">
                                        <p class="text">@lang('Ensuring your funds grow safely through our secure deposit process with world-class payment options.')</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>
@endsection

@push('script')
    <script>
        "use strict";
        (function($) {
            const amount = Number("{{ getAmount($order->total_amount) }}");
            var gateway;

            $('.gateway-input').on('change', function() {
                gatewayChange();
            });

            function gatewayChange() {
                let gatewayElement = $('.gateway-input:checked');
                let methodCode = gatewayElement.val();

                if (methodCode === 'main-balance') {
                    $('.gateway-info').addClass('d-none');
                    $('[name=currency]').val(`{{ gs('cur_text') }}`);
                    $('.final-amount').text(amount);
                    $('.processing-fee').text('0.00');
                    $('.gateway-conversion, .conversion-currency, .crypto-message').addClass('d-none');
                    $('.deposit-form').removeClass('adjust-height');
                    const mainBalance = parseFloat(`{{ auth()->user()->balance }}`);
                    if (amount > mainBalance) {
                        $('.deposit-form button[type=submit]').attr('disabled', true);
                    } else {
                        $('.deposit-form button[type=submit]').removeAttr('disabled');
                    }
                    return;
                } else {
                    $('.deposit-form button[type=submit]').removeAttr('disabled');
                    $('.gateway-info').removeClass('d-none');
                }

                gateway = gatewayElement.data('gateway');

                let processingFeeInfo =
                    `${parseFloat(gateway.percent_charge).toFixed(2)}% with ${parseFloat(gateway.fixed_charge).toFixed(2)} {{ __(gs('cur_text')) }} charge for payment gateway processing fees`;
                $('.proccessing-fee-info').attr('data-bs-original-title', processingFeeInfo);
                calculation();
            }

            $('.more-gateway-option').on('click', function() {
                let paymentList = $('.gateway-option-list');
                paymentList.find('.gateway-option').removeClass('d-none');
                $(this).addClass('d-none');
                paymentList.animate({
                    scrollTop: (paymentList.height() - 60)
                }, 'slow');
            });

            function calculation() {
                if (!gateway) return;

                let percentCharge = 0;
                let fixedCharge = 0;
                let totalPercentCharge = 0;

                if (amount) {
                    percentCharge = parseFloat(gateway.percent_charge);
                    fixedCharge = parseFloat(gateway.fixed_charge);
                    totalPercentCharge = parseFloat(amount / 100 * percentCharge);
                }

                let totalCharge = totalPercentCharge + fixedCharge;
                let totalAmount = amount + totalPercentCharge + fixedCharge;

                $('.final-amount').text(totalAmount.toFixed(2));
                $('.processing-fee').text(totalCharge.toFixed(2));
                $('[name=currency]').val(gateway.currency);
                $('.gateway-currency').text(gateway.currency);

                if (amount < Number(gateway.min_amount) || amount > Number(gateway.max_amount)) {
                    $(".deposit-form button[type=submit]").attr('disabled', true);
                } else {
                    $(".deposit-form button[type=submit]").removeAttr('disabled');
                }

                if (gateway.currency != "{{ gs('cur_text') }}" && gateway.method.crypto != 1) {
                    $('.deposit-form').addClass('adjust-height');
                    $('.gateway-conversion, .conversion-currency').removeClass('d-none');
                    $('.gateway-conversion').find('.deposit-info__input .conversion-text').html(
                        `1 {{ __(gs('cur_text')) }} = <span class="rate">${parseFloat(gateway.rate).toFixed(2)}</span> <span class="method_currency">${gateway.currency}</span>`
                    );
                    $('.in-currency').text(parseFloat(totalAmount * gateway.rate).toFixed(gateway.method.crypto == 1 ?
                        8 : 2));
                } else {
                    $('.gateway-conversion, .conversion-currency').addClass('d-none');
                    $('.deposit-form').removeClass('adjust-height');
                }

                if (gateway.method.crypto == 1) {
                    $('.crypto-message').removeClass('d-none');
                } else {
                    $('.crypto-message').addClass('d-none');
                }
            }

            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });

            $('.gateway-input').change();
        })(jQuery);
    </script>
@endpush
