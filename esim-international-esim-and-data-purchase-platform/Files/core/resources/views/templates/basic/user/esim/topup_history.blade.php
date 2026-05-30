@extends('Template::layouts.master')
@section('content')
    <div class="d-flex flex-between mb-3">
        <h5 class="mb-0">{{ __($pageTitle) }}</h5>
    </div>
    <div class="table--responsive mb-3">
        <table class="table table--custom table--responsive-sm">
            <thead>
                <tr>
                    <th>@lang('eSIM')</th>
                    <th>@lang('Plan')</th>
                    <th>@lang('Price')</th>
                    <th>@lang('Data')</th>
                    <th>@lang('Voice SMS')</th>
                    <th>@lang('Text SMS')</th>
                    <th>@lang('Validity')</th>
                    <th>@lang('Status')</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($topups as $topup)
                    <tr>
                        <td>{{ $topup->esim->iccid }}</td>
                        <td>{{ __($topup->name) }}</td>
                        <td>{{ showAmount($topup->price) }}</td>
                        <td>{{ dataVolume($topup->data_volume, isString: true) }}</td>
                        <td>{{ $topup->voice_quantity }} @lang('Minutes')</td>
                        <td>{{ $topup->sms_quantity }} @lang('SMS')</td>
                        <td>{{ $topup->validity, 'd M, Y' }} @lang('Days')</td>
                        <td>
                            @php echo $topup->statusBadge; @endphp
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="100%">{{ __($emptyMessage) }}</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if ($topups->hasPages())
        <div class="pagination-wrapper">
            {{ paginateLinks($topups) }}
        </div>
    @endif
@endsection
