@extends('Template::layouts.master')
@section('content')
    @php
        $installationSteps = getContent('esim_installation_steps.element', orderById: true);
    @endphp

    <div class="mb-3 flex-between">
        <h5 class="mb-0">{{ __($pageTitle) }}</h5>
        @if ($esim->isReloadable())
            <a href="{{ route('user.esim.topup.form', $esim->id) }}" class="btn btn--base btn--xsm" type="button"> <i class="las la-plus-circle"></i> @lang('Topup')</a>
        @endif
    </div>

    <div class="row gy-4">
        @if ($esim->isRefundable())
            <div class="col-md-12">
                <div class="card custom--card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                            <div class="text">
                                <h5 class="mb-1">@lang('Cancel eSIM')</h5>
                                <p>@lang('You need top pay') <span class="fw-bold">{{ showAmount(gs('refund_charge')) }}</span> @lang('to cancel the eSIM.')</p>
                            </div>
                            <button type="button" class="btn btn--danger btn--sm confirmationBtn" data-question="@lang('Are you sure to cancel the eSIM?')" data-action="{{ route('user.esim.cancel', $esim->id) }}"><i class="las la-times-circle"></i> @lang('Cancel')</button>
                        </div>
                    </div>
                </div>
            </div>
        @endif

        <div class="col-md-12">
            <div class="details-card">
                <div class="details-card__title">@lang('QR Code & Installation Guide')</div>
                <div class="details-card__body">
                    <div class="qr-code-container">
                        @if ($esim->qr_code_image)
                            <div class="text-start qr-code">
                                <div class="img">
                                    <img src="{{ $esim->qr_code_image }}" alt="">
                                </div>
                            </div>
                        @else
                            <div class="text-start qr-code">
                                <div class="img">
                                    <img src="{{ cryptoQR($esim->qr_code) }}" alt="">
                                </div>
                            </div>
                        @endif
                        <div class="installation-step">
                            <ol class="steps">
                                @foreach ($installationSteps as $step)
                                    <li>
                                        <div class="d-flex flex-column gap-1">
                                            <h6 class="steps-title">{{ __($step->data_values->heading) }}</h6>
                                            <p class="steps-desc">{{ __($step->data_values->description) }}</p>
                                        </div>
                                    </li>
                                @endforeach
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="details-card">
                <p class="details-card__title">@lang('eSIM Information')</p>
                <div class="details-card__body">
                    <ul class="details-card__list">
                        <li class="details-card__item">
                            <span class="label">@lang('ICCID')</span>
                            <span class="value">{{ $esim->iccid }}</span>
                        </li>
                        <li class="details-card__item">
                            <span class="label">@lang('Expiry Date')</span>
                            <span class="value">{{ showDateTime($esim->expiry_date, 'd M, Y') }}</span>
                        </li>
                        <li class="details-card__item phoneLi d-none">
                            <span class="label">@lang('Phone Number')</span>
                            <span class="value phoneNumber">..</span>
                        </li>
                        <li class="details-card__item networkSpeedLi d-none">
                            <span class="label">@lang('Network Speed')</span>
                            <span class="value networkSpeed">..</span>
                        </li>
                        <li class="details-card__item">
                            <span class="label">@lang('Remaining Data')</span>
                            <span class="value remainingData">..</span>
                        </li>
                        <li class="details-card__item minuteLi d-none">
                            <span class="label">@lang('Remaining Minutes')</span>
                            <span class="value"><span class="remainingMinutes"> .. </span> @lang('Minutes')</span>
                        </li>
                        <li class="details-card__item smsLi d-none">
                            <span class="label">@lang('Remaining SMS')</span>
                            <span class="value remainingSMS">..</span>
                        </li>
                        <li class="details-card__item">
                            <span class="label">@lang('Created At')</span>
                            <span class="value">{{ showDateTime($esim->created_at, 'd M, Y H:i A') }}</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="details-card">
                <p class="details-card__title">@lang('Plan Information')</p>
                <div class="details-card__body">
                    <li class="details-card__item">
                        <span class="label">@lang('Name')</span>
                        <span class="value">{{ $esim->orderItem->plan->name }}</span>
                    </li>
                    <li class="details-card__item">
                        <span class="label">@lang('Validity')</span>
                        <span class="value">{{ $esim->orderItem->plan->period }} @lang('Days')</span>
                    </li>
                    <li class="details-card__item">
                        <span class="label">@lang('Data')</span>
                        <span class="value">{{ $esim->orderItem->plan->readableDataVolume }}</span>
                    </li>

                    @if ($esim->orderItem->plan->voice_quantity != 0)
                        <li class="details-card__item">
                            <span class="label">@lang('Talk Times')</span>
                            <span class="value">{{ $esim->orderItem->plan->readableVoiceQuantity }}</span>
                        </li>
                    @endif
                    @if ($esim->orderItem->plan->sms_quantity != 0)
                        <li class="details-card__item">
                            <span class="label">@lang('SMS')</span>
                            <span class="value">{{ $esim->orderItem->plan->readableSmsQuantity }}</span>
                        </li>
                    @endif

                    @if ($esim->orderItem->plan->operator_name)
                        <li class="details-card__item">
                            <span class="label">@lang('Operator')</span>
                            <span class="value">{{ __($esim->orderItem->plan->operator_name) }}</span>
                        </li>
                    @endif

                    <li class="details-card__item">
                        <span class="label">@lang('Price')</span>
                        <span class="value">{{ showAmount($esim->orderItem->plan->convertedPrice) }}</span>
                    </li>

                    <li class="details-card__item">
                        <span class="label">@lang('Coverage')</span>
                        @if ($coverageCountries->count() == 1)
                            <span class="value"> {{ __($coverageCountries->first()->name) }} </span>
                        @else
                            <span class="value">
                                <a href="javascript:void(0)" data-bs-toggle="modal" data-bs-target="#coverageAreaModal" class="text--info">{{ $coverageCountries->count() . ' ' . trans('Countries') }}</a>
                            </span>

                            @include('Template::partials.coverage_modal', ['coverageCountries' => $coverageCountries])
                        @endif
                    </li>
                </div>
            </div>
        </div>
    </div>

    @if ($esim->isRefundable())
        <x-confirmation-modal />
    @endif
@endsection

@push('script')
    <script>
        (function($) {
            'use strict';

            $.ajax({
                url: "{{ route('user.esim.check.capacity') }}",
                method: 'POST',
                data: {
                    _token: '{{ csrf_token() }}',
                    esim_id: "{{ $esim->id }}"
                },
                success: function(response) {
                    if (response.status === 'success') {
                        let data = response.data;

                        if (data.phone != '--') {
                            $('.phoneLi').removeClass('d-none');
                            $('.phoneNumber').text(data.phone);
                        }

                        if (data.network_speed != '--') {
                            $('.networkSpeedLi').removeClass('d-none');
                            $('.networkSpeed').text(data.network_speed);
                        }

                        $('.remainingData').text(data.remaining);

                        if (data.remaining_voice && data.remaining_voice != '--') {
                            $('.minuteLi').removeClass('d-none');
                            $('.remainingMinutes').text(data.remaining_voice);
                        }

                        if (data.remaining_sms && data.remaining_sms != '--') {
                            $('.smsLi').removeClass('d-none');
                            $('.remainingSMS').text(data.remaining_sms + ' ' + `@lang('SMS')`);
                        }
                    }
                }
            });
        })(jQuery);
    </script>
@endpush
