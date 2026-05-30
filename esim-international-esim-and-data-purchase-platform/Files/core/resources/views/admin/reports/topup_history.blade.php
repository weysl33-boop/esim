@extends('admin.layouts.app')
@section('panel')
    <div class="row">
        <div class="col-lg-12">
            <div class="card">
                <div class="card-body p-0">
                    <div class="table-responsive--sm table-responsive">
                        <table class="table table--light style--two">
                            <thead>
                                <tr>
                                    <th>@lang('User')</th>
                                    <th>@lang('Plan')</th>
                                    <th>@lang('Data Qty')</th>
                                    <th>@lang('Voice Qty')</th>
                                    <th>@lang('SMS Qty')</th>
                                    <th>@lang('Price')</th>
                                    <th>@lang('Status')</th>
                                    <th>@lang('Created At')</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($topups as $topup)
                                    <tr>
                                        <td>
                                            <span class="fw-bold">{{ $topup->user->fullname }}</span>
                                            <br>
                                            <span class="small">
                                                <a href="{{ route('admin.users.detail', $topup->user_id) }}"><span>@</span>{{ $topup->user->username }}</a>
                                            </span>
                                        </td>
                                        <td>{{ __($topup->name) }}</td>
                                        <td>{{ dataVolume($topup->data_volume, isString: true) }}</td>
                                        <td>{{ $topup->voice_quantity . ' ' . __('Minutes') }}</td>
                                        <td>{{ $topup->sms_quantity . ' ' . __('SMS') }}</td>
                                        <td>{{ showAmount($topup->price) }}</td>
                                        <td>
                                            @php echo $topup->statusBadge; @endphp
                                        </td>
                                        <td>{{ showDateTime($topup->created_at, 'd M, Y') }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td class="text-muted text-center" colspan="100%">{{ __($emptyMessage) }}</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table><!-- table end -->
                    </div>
                </div>
                @if ($topups->hasPages())
                    <div class="card-footer py-4">
                        {{ paginateLinks($topups) }}
                    </div>
                @endif
            </div><!-- card end -->
        </div>
    </div>
@endsection

@push('breadcrumb-plugins')
    <x-search-form />
@endpush
