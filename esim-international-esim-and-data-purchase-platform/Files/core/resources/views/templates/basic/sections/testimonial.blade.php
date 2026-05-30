@php
    $testimonialElements = getContent('testimonial.element', false, orderById: true);
@endphp

<section class="testimonial-section my-120" data-aos="fade-up" data-aos-duration="1000">
    <div class="container">
        <div class="testimonial-slider">
            @foreach ($testimonialElements as $testimonialElement)
                <div class="testimonial-section__item">
                    <div class="testimonial-section__thumb">
                        <img class="testimonial-section__image" src="{{ frontendImage('testimonial', $testimonialElement->data_values?->customer_image, '720x725') }}" alt="image">
                    </div>
                    <div class="testimonial-section__content">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h4 class="testimonial-section__name">{{ __($testimonialElement->data_values->customer_name) }}</h4>
                                <p class="testimonial-section__title">{{ __($testimonialElement->data_values->customer_designation) }}</p>

                                <div class="testimonial-section__rank">
                                    @for ($i = 0; $i < $testimonialElement->data_values->rating; $i++)
                                        <div class="testimonial-section__star">
                                            <i class="fa-solid fa-star"></i>
                                        </div>
                                    @endfor
                                </div>
                            </div>

                            <div>
                                <svg xmlns="http://www.w3.org/2000/svg" width="68" height="68" viewBox="0 0 68 68" fill="none">
                                    <circle cx="34" cy="34" r="34" fill="#DAF1E4" />
                                    <path
                                        d="M35.7716 42.4739C38.7939 35.6145 45.1408 36.211 48.1684 39.9729C51.1959 43.7347 47.4075 48.5877 44.083 49.1841C40.7584 49.7806 35.4693 47.5438 35.4785 40.0633C35.4908 30.0973 45.9838 20.5489 47.1369 19.7104"
                                        stroke="white" stroke-width="3" stroke-linecap="round" />
                                    <path
                                        d="M18.0323 42.4739C21.0546 35.6145 27.4015 36.211 30.4291 39.9729C33.4566 43.7347 29.6683 48.5877 26.3437 49.1841C23.0191 49.7806 17.7301 47.5438 17.7393 40.0633C17.7515 30.0973 28.2446 20.5489 29.3976 19.7104"
                                        stroke="white" stroke-width="3" stroke-linecap="round" />
                                </svg>
                            </div>
                        </div>

                        <p class="testimonial-section__desc">{{ __($testimonialElement->data_values->description) }}</p>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</section>
