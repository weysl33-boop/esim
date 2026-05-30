@php
    $regionGroups = collect();

    foreach ($countries as $country) {
        // Get unique regions from plans
        $uniqueRegions = $country->plans->pluck('region.name')->filter()->unique();

        if ($uniqueRegions->isEmpty()) {
            $uniqueRegions = collect(['Country']);
        }

        foreach ($uniqueRegions as $region) {
            if (!$regionGroups->has($region)) {
                $regionGroups[$region] = collect();
            }
            $regionGroups[$region]->push($country);
        }
    }
@endphp

@if ($regionGroups->isEmpty())
    <h6 class="title mb-0">@lang('No countries found')</h6>
@else
    @foreach ($regionGroups as $region => $groupedCountries)
        <h6 class="text-muted fw-bold ps-2 mt-3">
            {{ ucfirst($region) }} @lang('eSIMs')
        </h6>

        @foreach ($groupedCountries->unique('id') as $country)
            <a class="search-box-list__item" href="{{ route('country.plans', $country->slug) }}">
                @if ($country->image)
                    <img class="flag" src="{{ getImage(getFilePath('countryFlag') . '/' . $country->image, getFileSize('countryFlag')) }}" alt="flag">
                @else
                    <span class="country-code-avatar">
                        {{ __($country->code) }}
                    </span>
                @endif

                <h6 class="title">{{ __($country->name) }}</h6>
            </a>
        @endforeach
    @endforeach
@endif
