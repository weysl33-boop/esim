@php
    $coverageContent = getContent('coverage.content', true);
@endphp
@extends('Template::layouts.frontend')
@section('content')
    <section class="destination mt-60 mb-120">
        <div class="container">
            <div class="destination-top">
                <div class="esim-plan-tab" role="tablist">
                    <button class="esim-plan-tab__btn active" data-bs-toggle="tab" data-bs-target="#esim-tab-pane-1" type="button" role="tab">@lang('Local eSIMs')</button>
                    <button class="esim-plan-tab__btn" data-bs-toggle="tab" data-bs-target="#esim-tab-pane-2" type="button" role="tab">@lang('Regional eSIMs')</button>
                    <button class="esim-plan-tab__btn" data-bs-toggle="tab" data-bs-target="#esim-tab-pane-3" type="button" role="tab">@lang('Global eSIMs')</button>
                </div>

                <div class="search-box" id="searchBox">
                    <div class="search-box-field">
                        <input class="search-box-field__input countrySearch" type="text" placeholder="@lang('Search your destination')">
                        <span class="search-box-field__icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-search-icon lucide-search">
                                <path d="m21 21-4.34-4.34" />
                                <circle cx="11" cy="11" r="8" />
                            </svg>
                        </span>
                    </div>

                    <div class="search-box-result">
                        <div class="search-box-list countryResults">

                        </div>
                    </div>
                </div>
            </div>

            <div class="esim-plan-tab-content tab-content">
                <div class="tab-pane fade show active" id="esim-tab-pane-1" role="tabpanel" tabindex="0">
                    <div class="row g-3 justify-content-center">
                        @foreach ($countries as $country)
                            <div class="col-sm-6 col-lg-4" data-aos="fade-up" data-aos-duration="1000">
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
                                            {{ $country['name'] }}
                                        </h5>
                                        <span class="esim-plan-card__price">
                                            @lang('From') {{ showAmount($country['converted_price']) }}
                                        </span>
                                    </div>
                                </a>
                            </div>
                        @endforeach
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
                    <div class="row gy-4 justify-content-start">
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

    @if ($sections->secs != null)
        @foreach (json_decode($sections->secs) as $sec)
            @include('Template::sections.' . $sec)
        @endforeach
    @endif
@endsection

@push('style')
    <style>
        .search-box {
            width: 100%;
            max-width: 300px;
        }
    </style>
@endpush

@push('script')
    <script>
        "use strict";
        (function($) {

            function toggleSearchBox() {
                if ($('#esim-tab-pane-1').hasClass('active')) {
                    $('#searchBox').show();
                } else {
                    $('#searchBox').hide();
                }
            }

            $('button[data-bs-toggle="tab"]').on('shown.bs.tab', function(e) {
                toggleSearchBox();
            });

            $(document).ready(function() {
                toggleSearchBox();
            });

            $('.countrySearch').on('input', function() {
                let keyword = $(this).val();

                const inputval = $(this).val().trim();

                if (inputval.length > 1) {
                    $('.search-box').addClass('show')
                } else {
                    $('.search-box').removeClass('show')
                }

                if (keyword.length < 2) {
                    $('.countryResults').empty();
                    return;
                }

                $.ajax({
                    type: "GET",
                    url: "{{ route('search.country') }}",
                    data: {
                        keyword: keyword
                    },
                    success: function(response) {
                        $('.countryResults').html(response.html);
                    },
                    error: function(xhr) {
                        console.error("Search error:", xhr.responseText);
                    }
                });
            });
        })(jQuery);
    </script>
@endpush
