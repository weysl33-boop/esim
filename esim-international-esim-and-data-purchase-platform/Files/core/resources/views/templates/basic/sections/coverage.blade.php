@php
    $coverageContent = getContent('coverage.content', true);
    $countries = App\Models\Country::active()
        ->whereHas('plans', function ($query) {
            $query->active()->whereHas('esimProvider', fn($provider) => $provider->active());
        })
        ->with([
            'plans' => function ($plan) {
                $plan->active()->whereHas('esimProvider', fn($provider) => $provider->active());
            },
        ])
        ->featured()
        ->orderBy('name', 'ASC')
        ->get()
        ->map(function ($country) {
            $plan = $country->plans->sortBy('converted_price')->first();
            $country->converted_price = $plan->converted_price;
            return $country;
        })
        ->toArray();

    $regions = App\Models\Region::active()
        ->whereNotIn('slug', ['local', 'global'])
        ->withCount([
            'plans' => function ($plan) {
                $plan->active()->whereHas('esimProvider', fn($provider) => $provider->active());
            },
        ])
        ->having('plans_count', '>', 0)
        ->orderBy('name', 'ASC')
        ->get();

    $globalPlanCount = App\Models\Plan::active()->global()->whereHas('esimProvider', fn($provider) => $provider->active())->count();
@endphp

<section class="coverage-area my-60">
    <div class="container">
        <div class="esim-plan-tab" role="tablist">
            <button class="esim-plan-tab__btn active" data-bs-toggle="tab" data-bs-target="#esim-tab-pane-1" type="button" role="tab">@lang('Popular eSIMs')</button>
            <button class="esim-plan-tab__btn" data-bs-toggle="tab" data-bs-target="#esim-tab-pane-2" type="button" role="tab">@lang('Regional eSIMs')</button>
            <button class="esim-plan-tab__btn" data-bs-toggle="tab" data-bs-target="#esim-tab-pane-3" type="button" role="tab">@lang('Global eSIMs')</button>
        </div>
        <div class="esim-plan-tab-content tab-content">
            <div class="tab-pane fade show active" id="esim-tab-pane-1" role="tabpanel" tabindex="0">
                <div class="row g-3 justify-content-center">
                    @foreach ($countries as $country)
                        <div class="col-sm-6 col-lg-4" data-aos="fade-up" data-aos-duration="1000" data-aos-delay="{{ $loop->index * 10 }}">
                            <a class="esim-plan-card" href="{{ route('country.plans', $country['slug']) }}">
                                @if ($country['image'])
                                    <img class="esim-plan-card__img" src="{{ getImage(getFilePath('countryFlag') . '/' . $country['image'], getFileSize('countryFlag')) }}" alt="image">
                                @else
                                    <span class="country-code-avatar">
                                        {{ __($country['code']) }}
                                    </span>
                                @endif
                                <div class="esim-plan-card__content">
                                    <h5 class="esim-plan-card__title">
                                        {{ __($country['name']) }}
                                    </h5>
                                    <span class="esim-plan-card__price">
                                        @lang('From') {{ showAmount($country['converted_price']) }}
                                    </span>
                                </div>
                            </a>
                        </div>
                    @endforeach
                </div>

                <div class="text-center mt-4 mt-sm-5">
                    <a class="btn btn-outline--base" href="{{ $coverageContent?->data_values?->button_url }}">
                        {{ __($coverageContent?->data_values?->button_text) }}
                    </a>
                </div>
            </div>

            <div class="tab-pane fade" id="esim-tab-pane-2" role="tabpanel" tabindex="0">
                <div class="row gy-4 justify-content-center">
                    @foreach ($regions as $region)
                        <div class="col-sm-6 col-lg-4">
                            <a class="esim-plan-card2" href="{{ route('region.plans', $region->slug) }}">
                                <div class="esim-plan-card2__top">
                                    <div class="esim-plan-card2__info">
                                        <h5 class="esim-plan-card2__title">
                                            {{ __($region->name) }}
                                        </h5>

                                        <span class="esim-plan-card2__plan">
                                            {{ strPlural('Plan', $region->plans_count) }}
                                        </span>
                                    </div>
                                    <div class="esim-plan-card2__icon">
                                        <i class="las la-arrow-right"></i>
                                    </div>
                                </div>
                                <img class="esim-plan-card2__map" src="{{ getImage(getFilePath('regionImage') . '/' . $region->region_image, getFileSize('regionImage')) }}" alt="image">
                            </a>
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="tab-pane fade" id="esim-tab-pane-3" role="tabpanel" tabindex="0">
                <div class="row gy-4 justify-content-center">
                    <div class="col-md-4">
                        @if ($globalPlanCount)
                            <a class="esim-plan-card2" href="{{ route('global.plans') }}">
                                <div class="esim-plan-card2__top">
                                    <div class="esim-plan-card2__info">
                                        <h5 class="esim-plan-card2__title">
                                            @lang('Global')
                                        </h5>

                                        <span class="esim-plan-card2__plan">
                                            {{ strPlural('Plan', $globalPlanCount) }}
                                        </span>
                                    </div>
                                    <div class="esim-plan-card2__icon">
                                        <i class="las la-arrow-right"></i>
                                    </div>
                                </div>
                            </a>
                        @else
                            <div class="text-center">
                                <x-empty-message message="No Global eSIMs available at the moment" />
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
