@extends('Template::layouts.frontend')
@section('content')
    <section class="my-120">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <form action="{{ route('user.deposit.insert') }}" method="post" class="deposit-form">
                        @csrf

                        @if ($topup)
                            <input type="hidden" name="topup_id" value="{{ $topup->id }}">
                        @endif
                        <input type="hidden" name="currency">

                        <div class="row justify-content-center gy-sm-4 gy-3">
                            <div class="col-lg-6">
                                <div class="payment-system-list is-scrollable gateway-option-list">
                                    @if ($topup)
                                        <label for="main-balance" class="payment-item gateway-option">
                                            <div class="payment-item__info">
                                                <span class="payment-item__check"></span>
                                                <span class="payment-item__name">@lang('eSIM Wallet')
                                                    ({{ showAmount(auth()->user()->balance) }})</span>
                                            </div>
                                            <div class="payment-item__thumb">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-wallet-icon lucide-wallet">
                                                    <path d="M19 7V4a1 1 0 0 0-1-1H5a2 2 0 0 0 0 4h15a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1" />
                                                    <path d="M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4" />
                                                </svg>
                                            </div>
                                            <input class="payment-item__radio gateway-input" data-gateway="wallet" id="main-balance" hidden type="radio" name="gateway" value="main-balance" checked>
                                        </label>
                                    @endif

                                    @foreach ($gatewayCurrency as $data)
                                        <label for="{{ titleToKey($data->name) }}" class="payment-item @if ($loop->index > 4) d-none @endif gateway-option">
                                            <div class="payment-item__info">
                                                <span class="payment-item__check"></span>
                                                <span class="payment-item__name">{{ __($data->name) }}</span>
                                            </div>
                                            <div class="payment-item__thumb">
                                                <img class="payment-item__thumb-img" src="{{ getImage(getFilePath('gateway') . '/' . $data->method->image) }}" alt="@lang('payment-thumb')">
                                            </div>
                                            <input class="payment-item__radio gateway-input" id="{{ titleToKey($data->name) }}" hidden data-gateway='@php echo json_encode($data) @endphp' type="radio" name="gateway" value="{{ $data->method_code }}" type="radio" name="gateway" value="{{ $data->method_code }}" @checked(old('gateway', $loop->first) == $data->method_code && $topup == null) data-min-amount="{{ showAmount($data->min_amount) }}" data-max-amount="{{ showAmount($data->max_amount) }}">
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
                                @if ($topup)
                                    <div class="payment-system-list p-3 mb-3">
                                        <h6 class="mb-4">@lang('Topup Plan Information')</h6>
                                        <div class="deposit-info">
                                            <div class="deposit-info__title">
                                                <p class="text"> @lang('Plan')</p>
                                            </div>
                                            <div class="deposit-info__input">
                                                <p class="text">
                                                    <span>{{ __($topup->name) }}</span>
                                                </p>
                                            </div>
                                        </div>

                                        <div class="deposit-info">
                                            <div class="deposit-info__title">
                                                <p class="text"> @lang('Data')</p>
                                            </div>
                                            <div class="deposit-info__input">
                                                <p class="text">
                                                    <span>{{ dataVolume($topup->data_volume, isString: true) }}</span>
                                                </p>
                                            </div>
                                        </div>

                                        @if ($topup->voice_quantity > 0)
                                            <div class="deposit-info">
                                                <div class="deposit-info__title">
                                                    <p class="text"> @lang('Voice')</p>
                                                </div>
                                                <div class="deposit-info__input">
                                                    <p class="text">
                                                        <span>{{ $topup->voice_quantity }} @lang('Minutes')</span>
                                                    </p>
                                                </div>
                                            </div>
                                        @endif

                                        @if ($topup->sms_quantity > 0)
                                            <div class="deposit-info">
                                                <div class="deposit-info__title">
                                                    <p class="text"> @lang('SMS')</p>
                                                </div>
                                                <div class="deposit-info__input">
                                                    <p class="text">
                                                        <span>{{ $topup->sms_quantity }} @lang('Messages')</span>
                                                    </p>
                                                </div>
                                            </div>
                                        @endif
                                        <div class="deposit-info">
                                            <div class="deposit-info__title">
                                                <p class="text"> @lang('Validity')</p>
                                            </div>
                                            <div class="deposit-info__input">
                                                <p class="text">
                                                    <span>{{ $topup->validity }} @lang('Days')</span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                @endif

                                <div class="payment-system-list p-3">
                                    <div class="deposit-info">
                                        <div class="deposit-info__title">
                                            <p class="text mb-0">@lang('Amount')</p>
                                        </div>
                                        @if ($topup)
                                            <div class="deposit-info__input">
                                                <div class="deposit-info__input-group input-group input--group">
                                                    <span class="input-group-text">{{ gs('cur_sym') }}</span>
                                                    <input type="text" class="form-control form--control amount" name="amount" value="{{ getAmount($topup->price) }}" readonly>
                                                </div>
                                            </div>
                                        @else
                                            <div class="deposit-info__input">
                                                <div class="deposit-info__input-group input-group input--group">
                                                    <span class="input-group-text">{{ gs('cur_sym') }}</span>
                                                    <input type="text" class="form-control form--control amount" name="amount" placeholder="@lang('00.00')" value="{{ old('amount') }}" autocomplete="off">
                                                </div>
                                            </div>
                                        @endif
                                    </div>
                                    <hr>

                                    @if (!$topup)
                                        <div class="deposit-info">
                                            <div class="deposit-info__title">
                                                <p class="text has-icon"> @lang('Limit')
                                                    <span></span>
                                                </p>
                                            </div>
                                            <div class="deposit-info__input">
                                                <p class="text"><span class="gateway-limit">@lang('0.00')</span>
                                                </p>
                                            </div>
                                        </div>
                                    @endif

                                    <div class="deposit-info">
                                        <div class="deposit-info__title">
                                            <p class="text has-icon">@lang('Processing Charge')
                                                <span data-bs-toggle="tooltip" title="@lang('Processing charge for payment gateways')" class="proccessing-fee-info"><i class="las la-info-circle"></i> </span>
                                            </p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p class="text"><span class="processing-fee">@lang('0.00')</span>
                                                {{ __(gs('cur_text')) }}
                                            </p>
                                        </div>
                                    </div>

                                    <div class="deposit-info total-amount pt-3">
                                        <div class="deposit-info__title">
                                            <p class="text">@lang('Total')</p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p class="text"><span class="final-amount">@lang('0.00')</span>
                                                {{ __(gs('cur_text')) }}</p>
                                        </div>
                                    </div>

                                    <div class="deposit-info gateway-conversion d-none total-amount pt-2">
                                        <div class="deposit-info__title">
                                            <p class="text">@lang('Conversion')
                                            </p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p class="text"></p>
                                        </div>
                                    </div>
                                    <div class="deposit-info conversion-currency d-none total-amount pt-2">
                                        <div class="deposit-info__title">
                                            <p class="text">
                                                @lang('In') <span class="gateway-currency"></span>
                                            </p>
                                        </div>
                                        <div class="deposit-info__input">
                                            <p class="text">
                                                <span class="in-currency"></span>
                                            </p>

                                        </div>
                                    </div>
                                    <div class="d-none crypto-message mb-3">
                                        @lang('Conversion with') <span class="gateway-currency"></span> @lang('and final value will Show on next step')
                                    </div>
                                    <button type="submit" class="btn btn--base w-100 mt-2" disabled>
                                        @lang('Confirm Deposit')
                                    </button>
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

@push('style')
    <style>
        .deposit-info__input:has(>.input--group) {
            max-width: 120px;
        }

        .input--group:has(.form--control[readonly]) {
            background: hsl(var(--black)/0.02) !important;
        }

        .input--group .form--control[readonly] {
            background: transparent !important;
        }
    </style>
@endpush

@push('script')
    <script>
        "use strict";
        (function($) {

            var amount = parseFloat($('.amount').val() || 0);
            var gateway, minAmount, maxAmount, methodCode;


            $('.amount').on('input', function(e) {
                amount = parseFloat($(this).val());
                if (!amount) {
                    amount = 0;
                }
                calculation();
            });

            $('.gateway-input').on('change', function(e) {
                gatewayChange();
            });

            function gatewayChange() {
                let gatewayElement = $('.gateway-input:checked');
                methodCode = gatewayElement.val();


                gateway = gatewayElement.data('gateway');
                minAmount = gatewayElement.data('min-amount');
                maxAmount = gatewayElement.data('max-amount');

                if (methodCode != 'main-balance') {
                    let processingFeeInfo =
                        `${parseFloat(gateway.percent_charge).toFixed(2)}% with ${parseFloat(gateway.fixed_charge).toFixed(2)} {{ __(gs('cur_text')) }} charge for payment gateway processing fees`
                    $(".proccessing-fee-info").attr("data-bs-original-title", processingFeeInfo);
                }
                calculation();
            }

            gatewayChange();

            $(".more-gateway-option").on("click", function(e) {
                let paymentList = $(".gateway-option-list");
                paymentList.find(".gateway-option").removeClass("d-none");
                $(this).addClass('d-none');
                paymentList.animate({
                    scrollTop: (paymentList.height() - 60)
                }, 'slow');
            });

            function calculation() {
                if (!gateway) return;
                $(".gateway-limit").text(minAmount + " - " + maxAmount);

                let percentCharge = 0;
                let fixedCharge = 0;
                let totalPercentCharge = 0;

                if (gateway == 'wallet') {
                    $(".final-amount").text(amount.toFixed(2));
                    $(".processing-fee").text('0.00');
                    $("input[name=currency]").val("{{ gs('cur_text') }}");
                    $(".deposit-form button[type=submit]").removeAttr('disabled');

                    $(".gateway-conversion, .conversion-currency").addClass('d-none');
                    $('.deposit-form').removeClass('adjust-height');
                    $('.crypto-message').addClass('d-none');
                    return;
                }

                if (amount) {
                    percentCharge = parseFloat(gateway?.percent_charge ?? 0);
                    fixedCharge = parseFloat(gateway?.fixed_charge ?? 0);
                    totalPercentCharge = parseFloat(amount / 100 * percentCharge);
                }

                let totalCharge = parseFloat(totalPercentCharge + fixedCharge);
                let totalAmount = parseFloat((amount || 0) + totalPercentCharge + fixedCharge);

                $(".final-amount").text(totalAmount.toFixed(2));
                $(".processing-fee").text(totalCharge.toFixed(2));
                $("input[name=currency]").val(gateway.currency);
                $(".gateway-currency").text(gateway.currency);

                if (amount < Number(gateway.min_amount) || amount > Number(gateway.max_amount)) {
                    $(".deposit-form button[type=submit]").attr('disabled', true);
                } else {
                    $(".deposit-form button[type=submit]").removeAttr('disabled');
                }

                if (gateway.currency != "{{ gs('cur_text') }}" && gateway?.method?.crypto != 1 && gateway != 'wallet') {
                    $('.deposit-form').addClass('adjust-height');

                    $(".gateway-conversion, .conversion-currency").removeClass('d-none');
                    $(".gateway-conversion").find('.deposit-info__input .text').html(
                        `1 {{ __(gs('cur_text')) }} = <span class="rate">${parseFloat(gateway.rate).toFixed(2)}</span>  <span class="method_currency">${gateway.currency}</span>`
                    );
                    $('.in-currency').text(parseFloat(totalAmount * gateway.rate).toFixed(gateway?.method?.crypto == 1 ? 8 : 2))
                } else {
                    $(".gateway-conversion, .conversion-currency").addClass('d-none');
                    $('.deposit-form').removeClass('adjust-height');
                }

                if (gateway?.method?.crypto == 1) {
                    $('.crypto-message').removeClass('d-none');
                } else {
                    $('.crypto-message').addClass('d-none');
                }
            }

            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
            var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl)
            })
            $('.gateway-input').change();
        })(jQuery);
    </script>
@endpush
