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
                                    <th><input type="checkbox" id="selectAll"></th>
                                    <th class="text-start">@lang('Name')</th>
                                    <th>@lang('Total Plan')</th>
                                    <th>@lang('Status')</th>
                                    <th>@lang('Action')</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($regions as $region)
                                    <tr>
                                        <td>
                                            <input type="checkbox" class="regionCheckbox" value="{{ $region->id }}">
                                        </td>

                                        <td>
                                            <div class="user gap-2">
                                                <div class="d-flex align-items-center gap-3 flex-wrap justify-content-end justify-content-md-start">
                                                    <span class="thumb d-none d-lg-block">
                                                        <img src="{{ getImage(getFilePath('regionImage') . '/' . $region->region_image, getFileSize('regionImage')) }}" alt="image">
                                                    </span>
                                                </div>
                                                <span>{{ $region->name }}</span>
                                            </div>
                                        </td>
                                        <td>
                                            <a href="{{ route('admin.plan.all') }}?region_id={{ $region->id }}">
                                                <span class="badge badge--primary">{{ $region->plans_count }}</span>
                                            </a>
                                        </td>
                                        <td>@php echo $region->statusBadge @endphp</td>
                                        <td>
                                            <div class="button--group">
                                                <button type="button" class="btn btn-sm btn-outline--primary editRegionBtn" data-region="{{ json_encode($region) }}"><i class="las la-pen"></i>@lang('Edit')</button>

                                                @if ($region->status == Status::DISABLE)
                                                    <button class="btn btn-sm btn-outline--success confirmationBtn" data-question="@lang('Are you sure to enable this region?')" data-action="{{ route('admin.destination.region.change.status', $region->id) }}" data-status="{{ Status::ENABLE }}" data-id="{{ $region->id }}"><i class="la la-eye"></i>@lang('Enable')</button>
                                                @else
                                                    <button class="btn btn-sm btn-outline--danger confirmationBtn" data-question="@lang('Are you sure to disable this region?')" data-action="{{ route('admin.destination.region.change.status', $region->id) }}" data-status="{{ Status::DISABLE }}" data-id="{{ $region->id }}"><i class="la la-eye-slash"></i>@lang('Disable')</button>
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
                @if ($regions->hasPages())
                    <div class="card-footer py-4">
                        {{ paginateLinks($regions) }}
                    </div>
                @endif
            </div>
        </div>
    </div>

    <div class="modal fade" id="regionModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form method="POST" enctype="multipart/form-data">
                    @csrf
                    <div class="modal-header">
                        <h5 class="modal-title">@lang('Edit Region')</h5>
                        <button type="button" class="close" data-bs-dismiss="modal">
                            <i class="las la-times"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="form-group imageGroup">
                                    <label>@lang('Region Image')</label>
                                    <x-image-uploader type="regionImage" name="region_image" class="w-100" :required="false" />
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="form-group bannerGroup">
                                    <label>@lang('Banner')</label>
                                    <x-image-uploader type="regionBanner" name="banner" class="w-100" id="bannerPreviewImage" :required="false" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn--primary h-45 w-100">@lang('Update')</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <x-fetch-modal />
    <x-confirmation-modal />
@endsection

@push('breadcrumb-plugins')
    <button class="btn btn-outline--primary fetchBtn" data-title="@lang('Fetch Regions')" data-action="{{ route('admin.destination.region.fetch.all') }}">
        <i class="las la-plus"></i>@lang('Fetch Regions')
    </button>
    <x-search-form />

    <div class="btn-group ms-2">
        <button type="button" class="btn btn-outline--info btn-sm bulkActionBtn" data-bs-toggle="dropdown" aria-expanded="false" disabled>
            <i class="las la-ellipsis-v"></i> @lang('Bulk Action')
        </button>
        <ul class="dropdown-menu">
            <li>
                <a href="javascript:void(0)" class="dropdown-item bulkActionOption confirmationBtn" data-question="@lang('Are you sure to enable selected countries?')" data-action="{{ route('admin.destination.region.change.bulk.status') }}" data-status="{{ Status::ENABLE }}">
                    <i class="las la-eye"></i> @lang('Enable')
                </a>
            </li>

            <li>
                <a href="javascript:void(0)" class="dropdown-item bulkActionOption confirmationBtn" data-question="@lang('Are you sure to disable selected countries?')" data-action="{{ route('admin.destination.region.change.bulk.status') }}" data-status="{{ Status::DISABLE }}"><i class="lar la-eye-slash"></i> @lang('Disable')</a>
            </li>
        </ul>
    </div>
@endpush

@push('script')
    <script>
        (function($) {
            "use strict";

            $(document).on('click', '.bulkActionOption', function(e) {
                e.preventDefault();

                let status = $(this).data('status');
                let selectedRegions = [];

                $('.regionCheckbox:checked').each(function() {
                    selectedRegions.push($(this).val());
                });

                if (selectedRegions.length === 0) {
                    notify('error', 'Please select at least one country.');
                    return;
                }

                showConfirmationModal(selectedRegions, status);
            });

            $(document).on('click', '.changeStatusBtn', function(e) {
                e.preventDefault();
                let status = $(this).data('status');
                let selectedRegions = [$(this).data('id')];
                showConfirmationModal(selectedRegions, status);
            });

            function showConfirmationModal(selectedRegions, status) {
                const modal = $('#confirmationModal');
                modal.find('form').append(`<input type="hidden" name="regions" value="${selectedRegions}">`);
                modal.find('form').append(`<input type="hidden" name="status" value="${status}">`);
                modal.find('form').off('submit');
                modal.modal('show');
            }

            $('#selectAll').on('change', function() {
                $('.regionCheckbox').prop('checked', $(this).prop('checked'));
            });

            function updateBulkActionState() {
                const anyChecked = $('.regionCheckbox:checked').length > 0;
                $('.bulkActionBtn').prop('disabled', !anyChecked);
            }

            $('.regionCheckbox, #selectAll').on('change', updateBulkActionState);


            $(document).ready(function() {
                $('#selectAll, .regionCheckbox').prop('checked', false);
            });

            $('.editRegionBtn').on('click', function() {
                let modal = $('#regionModal');
                let region = $(this).data('region');
                let url = `{{ route('admin.destination.region.update', ':id') }}`.replace(':id', region.id);

                modal.find('form').attr('action', url);
                modal.find('.modal-title').text(`@lang('Edit') - ${region.name}`);

                let imagePath = region.region_image ?
                    `{{ asset(getFilePath('regionImage')) }}/` + region.region_image :
                    `{{ getImage(null, getFileSize('regionImage')) }}`;
                $('.imageGroup .image-upload-preview').css('background-image', `url(${imagePath})`);

                let bannerPath = region.banner ?
                    `{{ asset(getFilePath('regionBanner')) }}/` + region.banner :
                    `{{ getImage(null, getFileSize('regionBanner')) }}`;

                $('.bannerGroup .image-upload-preview').css('background-image', `url(${bannerPath})`);

                modal.modal('show');
            });
        })(jQuery);
    </script>
@endpush
