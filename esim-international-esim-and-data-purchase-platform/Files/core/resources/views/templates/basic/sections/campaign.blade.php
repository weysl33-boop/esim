@php
    $content = getContent('campaign.content', true);
    $campaigns = App\Models\Campaign::active()->orderBy('id', 'DESC')->get();
@endphp
<section class="section-bg py-120">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="section-heading">
                    <h2 class="section-heading__title" data-underline-word="2" data-aos="fade-up" data-aos-duration="1500">{{ __($content->data_values?->heading ?? '') }}</h2>
                    <p class="section-heading__desc" data-aos="fade-up" data-aos-duration="1500" data-aos-delay="200">{{ __($content->data_values->description ?? '') }}</p>
                </div>
            </div>
        </div>

        <div class="row gy-4">
            @foreach ($campaigns as $campaign)
                <div class="col-lg-4 col-sm-6">
                    <div class="campaign">
                        <a href="{{ route('campaign.details', $campaign->slug) }}" class="campaign__link-overlay" aria-label="{{ __($campaign->title) }}"></a>
                        <div class="campaign__banner">
                            <img src="{{ getImage(getFilePath('campaign') . '/' . $campaign->banner, getFileSize('campaign')) }}" alt="{{ __($campaign->title) }}" class="img-fluid">
                            <span class="campaign__badge">{{ getAmount($campaign->discount) }}% @lang('OFF')</span>
                        </div>

                        <div class="campaign__content">
                            <h3 class="campaign__title">
                                <span class="campaign__title-link">{{ __($campaign->title) }}</span>
                            </h3>
                            <p class="campaign__discount">
                                @lang('Save up to') {{ getAmount($campaign->discount) }}% @lang('on selected plans')
                            </p>
                            <span class="cmn-btn campaign__btn">
                                {{ __('View Offers') }}
                            </span>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</section>
