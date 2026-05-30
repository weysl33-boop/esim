<div class="row gy-4">
    @foreach ($plans as $index => $plan)
        <div class="col-lg-6">
            @php
                $inputId = 'plan' . $index;
            @endphp
            <label class="choose-plan-item" for="{{ $inputId }}">
                <input class="d-none" type="radio" name="plan_id" 
                data-package_type="{{ $plan->package_type }}" 
                data-has_talk_time="{{ $plan->voice_quantity != 0 }}" 
                data-has_sms="{{ $plan->sms_quantity != 0 }}" 
                data-voice_quantity="{{ $plan->readableVoiceQuantity }}" 
                data-sms_quantity="{{ $plan->readableSmsQuantity }}" 
                data-price="{{ showAmount($plan->converted_price) }}" 
                data-validity="{{ $plan->period }}" 
                data-capacity="{{ $plan->readableDataVolume }}" 
                data-countries="{{ json_encode($plan->countries) }}" 
                data-reloadable="{{ $plan->reloadable ? __('Yes') : __('No') }}" 
                data-refundable="{{ $plan->refundable ? __('Yes') : __('No') }}" 
                data-has_campaign="{{ $plan->campaign ? true : false }}" 
                data-discount_percentage="{{ $plan->campaign?->discount ?? 0 }}" 
                data-discounted_price="{{ showAmount($plan->discountedPrice()) }}" 
                data-discount="{{ showAmount($plan->discountAmount()) }}" 
                id="{{ $inputId }}" value="{{ $plan->id }}" @checked($loop->first) />
                <span class="choose-plan-item__input"></span>

                <span class="choose-plan-item__header">
                    <span class="choose-plan-item__capacity">
                        {{ __($plan->name) }}
                    </span>
                    <span class="choose-plan-item__validity">
                        <span class="icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-timer-icon lucide-timer">
                                <line x1="10" x2="14" y1="2" y2="2" />
                                <line x1="12" x2="15" y1="14" y2="11" />
                                <circle cx="12" cy="14" r="8" />
                            </svg>
                        </span>
                        <span class="text">
                            @lang('For') {{ $plan->period }} @lang('days')
                        </span>
                    </span>
                </span>

                <span class="choose-plan-item__body">
                    <span class="choose-plan-item__price">
                        {{ showAmount($plan->discountedPrice()) }} @if ($plan->campaign)
                            <del>{{ showAmount($plan->converted_price) }}</del>
                        @endif
                    </span>
                    <div class="choose-plan-item__package-list">
                        @if ($plan->voice_quantity == -1 || $plan->voice_quantity > 0)
                            <span class="choose-plan-item__package">
                                <span class="icon">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-phone opacity-80" aria-hidden="true">
                                        <path d="M13.832 16.568a1 1 0 0 0 1.213-.303l.355-.465A2 2 0 0 1 17 15h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2A18 18 0 0 1 2 4a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2v3a2 2 0 0 1-.8 1.6l-.468.351a1 1 0 0 0-.292 1.233 14 14 0 0 0 6.392 6.384"></path>
                                    </svg>
                                </span>
                                {{ $plan->readableVoiceQuantity }}
                            </span>
                        @endif
                        @if ($plan->sms_quantity == -1 || $plan->sms_quantity > 0)
                            <span class="choose-plan-item__package">
                                <span class="icon">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-message-circle opacity-80" aria-hidden="true">
                                        <path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"></path>
                                    </svg>
                                </span>
                                {{ $plan->readableSmsQuantity }}
                            </span>
                        @endif
                    </div>
                </span>
            </label>
        </div>
    @endforeach
</div>

@push('script')
    <script>
        (function($) {
            "use strict";

            function updateCoverageAreaList(countries) {
                let modal = $('#coverageAreaModal');
                let flagUrl = "{{ asset(getFilePath('countryFlag')) }}";
                let html = '';
                $.each(countries, function(index, country) {
                    html += `<li class="list-group-item">`;
                    if (country.image) {
                        html += `<img class="country-flag" src="${flagUrl}/${country.image}"alt="flag">`;
                    } else {
                        html += `<span class="country-code">${country.code}</span>`;
                    }
                    html += `<h6 class="country-name">${country.name}</h6></li>`;
                });

                html += `
                    <li class="list-group-item d-none no-data">
                        <h6 class="w-100 h-100 empty-title text-center text-muted mb-0">
                            No Country Available.
                        </h6>
                    </li>
                `;
                modal.find('.list-group--coverage').html(html);

                if (Object.keys(countries).length == 1) {
                    $('.coverageLink').text(countries[0].name);
                } else {
                    let link = `<a href="javascript:void(0)" class="text--info" data-bs-toggle="modal" data-bs-target="#coverageAreaModal">${Object.keys(countries).length} @lang('Countries')</a>`;
                    $('.coverageLink').html(link);
                }
            }

            function updatePlanDetails(planInput) {
                const data = $(planInput).data();

                if (data.package_type == 'DATA') {
                    $('.talkTimeWrapper').addClass('d-none');
                    $('.smsWrapper').addClass('d-none');
                } else {
                    if (data.has_talk_time) {
                        $('.talkTimeWrapper').removeClass('d-none');
                        $('.talkTime').text(data.voice_quantity);
                    } else {
                        $('.talkTimeWrapper').addClass('d-none');
                        $('.talkTime').text('');
                    }

                    if (data.has_sms) {
                        $('.smsWrapper').removeClass('d-none');
                        $('.smsQty').text(data.sms_quantity);
                    } else {
                        $('.smsWrapper').addClass('d-none');
                        $('.smsQty').text('');
                    }
                }

                $('.dataPrice').text(data.price);
                $('.dataValidity').text(data.validity + ' Days');
                $('.dataCapacity').text(data.capacity);
                $('.rechargeable').text(data.reloadable);
                $('.refundable').text(data.refundable);


                let price = data.price;
                if (data.has_campaign) {
                    $('.discountPercentage').text(data.discount_percentage + '%');
                    $('.discount').text(data.discount);
                    $('.discountWrapper').removeClass('d-none');
                    price = data.discounted_price;
                } else {
                    $('.discountWrapper').addClass('d-none');
                    $('.discountPercentage').text('');
                    $('.discount').text('');
                }

                $('.dataTotalPrice').text(price);
            }

            const firstPlan = $('input[name="plan_id"]:checked');
            if (firstPlan.length) {
                updatePlanDetails(firstPlan[0]);
                updateCoverageAreaList(firstPlan.data('countries'));
            }

            $('input[name="plan_id"]').on('change', function() {
                updatePlanDetails(this);
                let countries = $(this).data('countries');
                updateCoverageAreaList(countries);
            });
        })(jQuery);
    </script>
@endpush
