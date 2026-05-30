@extends('admin.layouts.app')
@section('panel')
    <form action="{{ route('admin.campaign.store', $campaign?->id ?? 0) }}" method="POST" enctype="multipart/form-data">
        @csrf
        <div class="row gy-4">
            <div class="col-lg-5">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-12">
                                <div class="form-group">
                                    <label>@lang('Banner')</label>
                                    <x-image-uploader name="banner" type="campaign" :required="$campaign ? false : true" image="{{ $campaign?->banner }}" class="w-100" />
                                </div>
                            </div>
                            <div class="col-lg-12">
                                <div class="form-group">
                                    <div class="d-flex justify-content-between">
                                        <label>@lang('Title')</label>
                                        <a href="javascript:void(0)" class="buildSlug"><i class="las la-link"></i> @lang('Make Slug')</a>
                                    </div>
                                    <input type="text" name="title" class="form-control" value="{{ old('title', $campaign?->title) }}" required>
                                </div>
                                <div class="form-group">
                                    <div class="d-flex justify-content-between">
                                        <label>@lang('Slug')</label>
                                        <div class="slug-verification d-none"></div>
                                    </div>
                                    <input type="text" name="slug" class="form-control" value="{{ old('slug', $campaign?->slug) }}" required>
                                </div>
                                <div class="form-group">
                                    <label>@lang('Discount')</label>
                                    <div class="input-group">
                                        <input type="number" name="discount" class="form-control" value="{{ old('discount', $campaign ? getAmount($campaign->discount) : 0) }}" required>
                                        <span class="input-group-text">%</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-7">
                <div class="card bl--5 border--primary mb-3">
                    <div class="card-body">
                        <p class="text--primary">@lang('Select types and related option to see all plans. After that you can add plans to the campaign.')</p>
                        <p class="text--warning">@lang('If any of the selected plans are already assigned to another campaign, they will be automatically removed from the previous campaign and added to this campaign.')</p>
                    </div>
                </div>
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="form-group">
                                    <label>@lang('Plan Type')</label>
                                    <select name="plan_type" class="form-control planType">
                                        <option value="" selected disabled>@lang('Select One')</option>
                                        <option value="local">@lang('Local')</option>
                                        <option value="continental">@lang('Continental')</option>
                                        <option value="global">@lang('Global')</option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-lg-6">
                                <div class="option-wrapper"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row mt-3">
                    <div class="col-lg-6">
                        <div class="card fixed-height planWrapper">
                            <div class="card-body">
                                <div class="no-plan-selected w-100 h-100 d-flex align-items-center justify-content-center">
                                    <p>@lang('Please select plan type & related fields.')</p>
                                </div>
                                <div class="plan-wrapper d-none"></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="card fixed-height selectedPlanWrapper">
                            <div class="card-body">
                                @if ($campaign?->plans->count() <= 0)
                                    <div class="no-plan-selected w-100 h-100 d-flex align-items-center justify-content-center">
                                        <p>@lang('There is no plan selected.')</p>
                                    </div>
                                @endif
                                <div class="selected-plan-wrapper @if ($campaign?->plans->count() <= 0) d-none @endif">
                                    @foreach ($campaign?->plans ?? [] as $plan)
                                        <div class="plan-item" data-id="{{ $plan->id }}">
                                            <input name="plans[]" value="{{ $plan->id }}" hidden>
                                            <div class="d-flex align-items-center justify-content-between">
                                                <div class="d-flex flex-column gap-2">
                                                    <h6 class="name">{{ __($plan->name) }}</h6>
                                                    <span class="price text--small">{{ showAmount($plan->retail_price, currencyFormat: false) }} {{ __(gs('cur_text')) }}</span>
                                                </div>
                                                <button type="button" class="remove-plan" data-id="{{ $plan->id }}"><i class="las la-times"></i></button>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mt-3">
            <div class="card-header">
                <h5 class="mb-0">@lang('SEO Configuration')</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-xl-4">
                        <div class="form-group">
                            <label>@lang('SEO Image')</label>
                            <x-image-uploader name="seo_image" class="w-100" :imagePath="getImage(getFilePath('seo') . '/' . ($campaign?->seo_content?->image ?? ''), getFileSize('seo'))" id="seoImage" :size="getFileSize('seo')" :required="false" />
                        </div>
                    </div>
                    <div class="col-xl-8 mt-xl-0 mt-4">
                        <div class="form-group select2-parent position-relative">
                            <label>@lang('Meta Keywords')</label>
                            <small class="ms-2 mt-2">@lang('Separate multiple keywords by') <code>,</code> (@lang('comma')) @lang('or') <code>@lang('enter')</code> @lang('key')</small>
                            <select name="keywords[]" class="form-control select2-auto-tokenize" multiple="multiple">
                                @foreach (old('keywords', $campaign?->seo_content?->keywords ?? []) as $keyword)
                                    <option value="{{ $keyword }}" selected>{{ __($keyword) }}</option>
                                @endforeach
                            </select>
                        </div>

                        <div class="form-group">
                            <label>@lang('Meta Robots') <small>(@lang('optional'))</small></label>
                            <input type="text" class="form-control" name="meta_robots" value="{{ old('meta_robots', $campaign?->seo_content?->meta_robots) }}" placeholder="e.g. noindex, follow">
                        </div>

                        <div class="form-group">
                            <label>@lang('Meta Description')</label>
                            <textarea name="description" rows="3" class="form-control">{{ old('description', $campaign?->seo_content?->description) }}</textarea>
                        </div>
                        <div class="form-group">
                            <label>@lang('Social Title')</label>
                            <input type="text" class="form-control" name="social_title" value="{{ old('social_title', $campaign?->seo_content?->social_title) }}" />
                        </div>
                        <div class="form-group">
                            <label>@lang('Social Description')</label>
                            <textarea name="social_description" rows="3" class="form-control">{{ old('social_description', $campaign?->seo_content?->social_description) }}</textarea>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mt-3">
            <div class="card-body">
                <button type="submit" class="btn btn--primary h-45 w-100">@lang('Submit')</button>
            </div>
        </div>
    </form>
@endsection

@isset($campaign)
    @push('breadcrumb-plugins')
        <a href="{{ route('admin.campaign.create') }}" class="btn btn-sm btn-outline--primary"><i class="las la-plus"></i>@lang('Add New')</a>
    @endpush
@endisset

@push('script')
    <script>
        (function($) {
            'use strict';
            let currentPage = 1;
            let lastPage = 100;

            $('.buildSlug').on('click', function() {
                let closestForm = $(this).closest('form');
                let title = closestForm.find('[name=title]').val();
                closestForm.find('[name=slug]').val(title);
                closestForm.find('[name=slug]').trigger('input');
            });

            $('[name=slug]').on('input', function() {
                let closestForm = $(this).closest('form');
                closestForm.find('[type=submit]').addClass('disabled');
                let slug = $(this).val();
                slug = slug.toLowerCase().replace(/ /g, '-').replace(/[^\w-]+/g, '');
                $(this).val(slug);

                if (slug) {
                    closestForm.find('.slug-verification').removeClass('d-none');
                    closestForm.find('.slug-verification').html(`
                        <small class="text--info"><i class="las la-spinner la-spin"></i> @lang('Checking')</small>
                    `);

                    let checkUrl = "{{ route('admin.campaign.check.slug', $campaign?->id ?? 0) }}";
                    $.get(checkUrl, {
                        slug: slug
                    }, function(response) {
                        if (!response.exists) {
                            closestForm.find('.slug-verification').html(`
                                <small class="text--success"><i class="las la-check"></i> @lang('Available')</small>
                            `);
                            closestForm.find('[type=submit]').removeClass('disabled');
                        } else {
                            closestForm.find('.slug-verification').html(`
                                <small class="text--danger"><i class="las la-times"></i> @lang('Slug already exists')</small>
                            `);
                        }
                    });
                } else {
                    closestForm.find('.slug-verification').addClass('d-none');
                }
            });

            if ($('[name=slug]').val()) {
                $('[name=slug]').trigger('input');
            }

            $('.planType').on('change', function() {
                let type = $(this).val();
                let html = '';
                currentPage = 1;
                lastPage = 100;

                if (type == 'local') {
                    html += `<div class="form-group">
                                <label>@lang('Country')</label>
                                <select name="country_id" class="form-control select2Country">
                                    <option value="" selected disabled>@lang('Select One')</option>
                                    @foreach ($countries as $country)
                                        <option value="{{ $country->id }}">{{ $country->name }}</option>
                                    @endforeach
                                </select>
                            </div>`;
                    $('.option-wrapper').html(html);
                    initSelect2('.option-wrapper select.select2Country');

                } else if (type == 'continental') {
                    html += `<div class="form-group">
                                <label>@lang('Continent')</label>
                                <select name="continent_id" class="form-control select2Contient">
                                    <option value="" selected disabled>@lang('Select One')</option>
                                    @foreach ($regions as $region)
                                        <option value="{{ $region->id }}">{{ $region->name }}</option>
                                    @endforeach
                                </select>
                            </div>`;

                    $('.option-wrapper').html(html);
                    initSelect2('.option-wrapper select.select2Contient');
                } else {
                    $('.option-wrapper').html('');
                    getPlans();
                }
            });

            $(document).on('change', '[name=country_id]', function() {
                currentPage = 1;
                lastPage = 100;
                getPlans();
            });
            $(document).on('change', '[name=continent_id]', function() {
                currentPage = 1;
                lastPage = 100;
                getPlans();
            });

            function getPlans() {
                let type = $('.planType').val();
                let countryId = 0;
                let regionId = 0;

                if (type == 'local') {
                    countryId = $('[name=country_id]').val();
                    if (!countryId) return false;
                }

                if (type == 'continental') {
                    regionId = $('[name=continent_id]').val();
                    if (!regionId) return false;
                }

                if (currentPage > lastPage) return false;

                $.ajax({
                    type: "GET",
                    url: "{{ route('admin.campaign.plans') }}",
                    data: {
                        type: type,
                        country_id: countryId,
                        region_id: regionId,
                        page: currentPage
                    },
                    dataType: "JSON",
                    success: function(response) {
                        if (response.status == 'success') {
                            let plans = response.plans?.data;
                            let html = '';

                            if (currentPage == 1) {
                                $('.plan-wrapper').html('');
                            }

                            if (plans?.length > 0) {
                                plans.forEach(plan => {
                                    html += `
                                        <div class="plan-item" data-id="${plan.id}" data-name="${plan.name}" data-price="${parseFloat(plan.retail_price).toFixed(2)} {{ __(gs('cur_text')) }}">
                                            <h6 class="name">${plan.name}</h6>
                                            <span class="price text--small">${parseFloat(plan.retail_price).toFixed(2)} {{ __(gs('cur_text')) }}</span>
                                        </div>
                                    `;
                                });

                                $('.plan-wrapper').append(html).removeClass('d-none');
                                $('.plan-wrapper').siblings('.no-plan-selected').addClass('d-none');

                                currentPage = response.current_page;
                                lastPage = response.pages;
                            } else {
                                if (currentPage == 1) {
                                    html += `<div class="no-plan-selected w-100 h-100 d-flex align-items-center justify-content-center">
                                                <p>@lang('There is no plans available right now.')</p>
                                            </div>`;
                                    $('.plan-wrapper').html(html).removeClass('d-none');
                                    $('.plan-wrapper').siblings('.no-plan-selected').addClass('d-none');
                                }
                            }
                        }
                    }
                });
            }

            $('.planWrapper').on('scroll', function() {
                if ($(this).scrollTop() + $(this).innerHeight() >= $(this)[0].scrollHeight) {
                    currentPage++;
                    getPlans();
                }
            });

            $(document).on('click', '.plan-wrapper .plan-item', function() {
                if ($(this).hasClass('selected')) {
                    $('.selected-plan-wrapper').find('.plan-item[data-id="' + $(this).data('id') + '"]').remove();
                    $(this).removeClass('selected');

                    if ($('.selected-plan-wrapper').find('.plan-item').length == 0) {
                        $('.selected-plan-wrapper').addClass('d-none');
                        $('.selected-plan-wrapper').siblings('.no-plan-selected').removeClass('d-none');
                    }

                    return false;
                }

                let id = $(this).data('id');
                let name = $(this).data('name');
                let price = $(this).data('price');

                let html = `
                    <div class="plan-item" data-id="${id}">
                        <input name="plans[]" value="${id}" hidden>
                        <div class="d-flex align-items-center justify-content-between">
                            <div class="d-flex flex-column gap-2">
                                <h6 class="name">${name}</h6>
                                <span class="price text--small">${price}</span>
                            </div>
                            <button type="button" class="remove-plan" data-id="${id}"><i class="las la-times"></i></button>
                        </div>
                    </div>
                `;

                $('.selected-plan-wrapper').append(html).removeClass('d-none');
                $('.selected-plan-wrapper').siblings('.no-plan-selected').addClass('d-none');
                $(this).addClass('selected');
            });

            $(document).on('click', '.remove-plan', function() {
                let id = $(this).data('id');
                $(this).closest('.plan-item').remove();
                $('.plan-wrapper').find(`.plan-item[data-id="${id}"]`).removeClass('selected');

                if ($('.selected-plan-wrapper').find('.plan-item').length == 0) {
                    $('.selected-plan-wrapper').addClass('d-none');
                    $('.selected-plan-wrapper').siblings('.no-plan-selected').removeClass('d-none');
                }
            })
        })(jQuery);
    </script>
@endpush

@push('style')
    <style>
        .fixed-height {
            height: 415px;
            overflow-y: auto;
        }

        .plan-item {
            border: 1px solid #f1f1f1;
            padding: 10px 12px;
            border-radius: 4px;
            margin-bottom: 8px;
        }

        .plan-wrapper,
        .selected-plan-wrapper {
            height: 100%;
        }

        .plan-wrapper .plan-item {
            cursor: pointer;
        }

        .plan-item .name {
            font-size: 14px;
        }

        .plan-item.selected {
            border-color: #4634ff59;
            background: #4634ff14;
        }
    </style>
@endpush
