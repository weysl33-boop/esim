@extends('admin.layouts.app')
@section('panel')
    <div class="row">
        <div class="col-lg-12">
            <div class="card">
                <div class="card-body p-0">
                    <div class="table-responsive--md table-responsive">
                        <table class="table table--light style--two">
                            <thead>
                                <tr>
                                    <th>@lang('Campaign')</th>
                                    <th>@lang('Discount')</th>
                                    <th>@lang('Total Plans')</th>
                                    <th>@lang('Status')</th>
                                    <th>@lang('Action')</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($campaigns as $campaign)
                                    <tr>
                                        <td>
                                            <div class="user">
                                                <div class="d-flex align-items-center gap-2 flex-wrap justify-content-end justify-content-md-start">
                                                    <span class="thumb">
                                                        <img src="{{ getImage(getFilePath('campaign') . '/' . $campaign->banner, getFileSize('campaign')) }}" alt="image">
                                                    </span>
                                                    <span>{{ __($campaign->title) }}</span>
                                                </div>
                                            </div>
                                        </td>
                                        <td>{{ showAmount($campaign->discount, currencyFormat: false) }}%</td>
                                        <td>{{ $campaign->plans_count }}</td>
                                        <td>@php echo $campaign->statusBadge @endphp</td>
                                        <td>
                                            <div class="button--group">
                                                <a href="{{ route('admin.campaign.create', $campaign->id) }}" class="btn btn-sm btn-outline--primary"><i class="las la-pen"></i>@lang('Edit')</a>

                                                @if ($campaign->status == Status::DISABLE)
                                                    <button class="btn btn-sm btn-outline--success confirmationBtn" data-question="@lang('Are you sure to enable this country?')" data-action="{{ route('admin.campaign.status', $campaign->id) }}">
                                                        <i class="la la-eye"></i>@lang('Enable')
                                                    </button>
                                                @else
                                                    <button class="btn btn-sm btn-outline--danger confirmationBtn" data-question="@lang('Are you sure to disable this country?')" data-action="{{ route('admin.campaign.status', $campaign->id) }}">
                                                        <i class="la la-eye-slash"></i>@lang('Disable')
                                                    </button>
                                                @endif
                                            </div>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td class="text-muted text-center" colspan="100%">{{ __($emptyMessage) }}</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>

                @if ($campaigns->hasPages())
                    <div class="card-footer py-4">
                        {{ paginateLinks($campaigns) }}
                    </div>
                @endif
            </div>
        </div>
    </div>
    <x-confirmation-modal />
@endsection

@push('breadcrumb-plugins')
    <a href="{{ route('admin.campaign.create') }}" class="btn btn-sm btn-outline--primary"><i class="las la-plus"></i>@lang('Add New')</a>
@endpush
