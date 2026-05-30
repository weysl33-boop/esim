@extends('Template::layouts.frontend')
@section('content')
    @php $content = getContent('plan_selection.content', true); @endphp

    <section class="choose-plan my-120">
        <div class="container">
            <div class="section-heading">
                <h2 class="section-heading__title">
                    {{ __($content?->data_values?->heading) }}
                </h2>
                <p class="section-heading__desc">
                    {{ __($content?->data_values?->description) }}
                </p>
            </div>

            <form action="{{ route('user.plan.purchase') }}" method="POST">
                @csrf
                <div class="row gy-4">
                    <div class="col-lg-8 ">
                        <div class="choose-plan-item-container">
                            @include('Template::partials.plan_cards', ['plans' => $plans])
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="choose-plan-sidebar">
                            <div class="choose-plan-sidebar__header">
                                @if (isset($campaign) && isset($banner))
                                    <div class="choose-plan-campaign-banner mb-3">
                                        <img src="{{ $banner }}" alt="{{ __($campaign->title) }}">
                                        <span class="choose-plan-campaign-badge">{{ getAmount($campaign->discount) }}% @lang('OFF')</span>
                                    </div>
                                @endif
                                <div class="choose-plan-info">
                                    @if (isset($flag) || isset($flagCode))
                                        <div class="choose-plan-info__flag">
                                            @if (isset($flag))
                                                <img src="{{ $flag }}" alt="@lang('flag')">
                                            @elseif(isset($flagCode))
                                                <span class="country-code-avatar">
                                                    {{ $flagCode }}
                                                </span>
                                            @endif
                                        </div>
                                    @endif
                                    <div class="choose-plan-info__content">
                                        <h6 class="choose-plan-info__title">{{ __($title ?? '') }}</h6>
                                        <p class="choose-plan-info__desc">{{ $subtitle ?? __($content?->data_values?->description) }}</p>
                                    </div>
                                </div>
                            </div>
                            @include('Template::partials.purchase_info')
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </section>

    @include('Template::sections.work_process')
    @include('Template::sections.testimonial')
    @include('Template::partials.coverage_modal')
@endsection

@push('style')
    <style>
        .scroll-top {
            bottom: 84px;
        }

        .choose-plan-campaign-banner {
            position: relative;
            border-radius: 10px;
            overflow: hidden;
        }

        .choose-plan-campaign-banner img {
            width: 100%;
            height: 120px;
            object-fit: cover;
            display: block;
        }

        .choose-plan-campaign-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: hsl(var(--base));
            color: hsl(var(--white));
            font-size: 12px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 999px;
        }
    </style>
@endpush
