@foreach ($coverageCountries as $country)
    <li class="list-group-item">
        @if ($country->image)
            <img class="country-flag" src="{{ getImage(getFilePath('countryFlag') . '/' . $country->image, getFileSize('countryFlag')) }}" alt="@lang('flag')">
        @else
            <span class="country-code">{{ $country->code }}</span>
        @endif
        <h6 class="country-name">{{ __($country->name) }}</h6>
    </li>
@endforeach
<!-- No data message -->
<li class="list-group-item d-none no-data">
    <h6 class="w-100 h-100 empty-title text-center text-muted mb-0">
        @lang('No Country Available.')
    </h6>
</li>
