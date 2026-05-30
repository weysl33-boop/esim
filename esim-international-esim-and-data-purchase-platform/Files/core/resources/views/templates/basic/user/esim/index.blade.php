@extends('Template::layouts.master')
@section('content')
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <h5 class="mb-0">{{ __($pageTitle) }}</h5>
        <div>
            <a href="{{ route('destination') }}" class="btn btn-outline--base btn--xsm"><i class="las la-arrow-right"></i> @lang('Purchase Now')</a>
            @if (Route::is('user.esim.active'))
                <a href="{{ route('user.esim.expired') }}" class="btn btn--xsm btn-outline--dark"> <i class="las la-clock"></i> @lang('Expired eSIMs')</a>
            @else
                <a href="{{ route('user.esim.active') }}" class="btn btn--xsm btn-outline--dark"> <i class="las la-list"></i> @lang('Active eSIMs')</a>
            @endif
        </div>
    </div>
    <div class="table--responsive mb-3">
        <table class="table table--custom table--responsive-sm">
            <thead>
                <tr>
                    <th>@lang('Plan')</th>
                    <th>@lang('Phone')</th>
                    <th>@lang('Price')</th>
                    <th>@lang('Capacity')</th>
                    <th>@lang('Period')</th>
                    <th>@lang('Expiry Date')</th>
                    <th>@lang('Action')</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($esims as $esim)
                    @php
                        $plan = $esim->orderItem->plan;
                    @endphp
                    <tr>
                        <td>
                            <span @if (isset($plan->name) && strlen($plan->name) > 30) data-bs-toggle="tooltip" data-bs-title="{{ __($plan->name) }}" @endif>{{ __($plan->name ? strLimit(__($plan->name), 30) : 'N/A') }}</span>
                        </td>
                        <td>{{ $esim->phone_number ?? 'N/A' }}</td>
                        <td>{{ showAmount($esim->orderItem->price) }}</td>
                        <td>{{ $plan->readableDataVolume }}</td>
                        <td>{{ $plan->period }} @lang('Days')</td>
                        <td>{{ showDateTime($esim->expiry_date, 'd M, Y') }}</td>
                        <td>
                            <div class="d-flex align-items-center justify-content-end gap-2">
                                <button type="button" class="btn btn--xsm btn-outline--base qrCodeBtn text-nowrap" data-id="{{ $esim->id }}" data-qr_code_image="{{ $esim->qr_code_image }}" data-url="{{ route('user.esim.get.qr', $esim->id) }}" data-bs-toggle="tooltip" data-bs-title="View QR Code">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-qr-code-icon lucide-qr-code">
                                        <rect width="5" height="5" x="3" y="3" rx="1" />
                                        <rect width="5" height="5" x="16" y="3" rx="1" />
                                        <rect width="5" height="5" x="3" y="16" rx="1" />
                                        <path d="M21 16h-3a2 2 0 0 0-2 2v3" />
                                        <path d="M21 21v.01" />
                                        <path d="M12 7v3a2 2 0 0 1-2 2H7" />
                                        <path d="M3 12h.01" />
                                        <path d="M12 3h.01" />
                                        <path d="M12 16v.01" />
                                        <path d="M16 12h1" />
                                        <path d="M21 12v.01" />
                                        <path d="M12 21v-1" />
                                    </svg>
                                </button>
                                <a href="{{ route('user.esim.detail', $esim->id) }}" class="btn btn--xsm btn-outline--base">
                                    <i class="las la-desktop"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="100%">
                            @if (Route::is('user.esim.active'))
                                @lang('You have not purchased any eSIM yet.')
                            @else
                                @lang('There is no expired eSIM exists.')
                            @endif
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if ($esims->hasPages())
        <div class="pagination-wrapper">
            {{ paginateLinks($esims) }}
        </div>
    @endif

    @if (Route::is('user.esim.active'))
        <div class="modal custom--modal qr--modal fade" id="qrCodeModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-sm">
                <div class="modal-content">
                    <div class="modal-body">
                        <button type="button" class="btn btn--xsm btn--close" data-bs-dismiss="modal" aria-label="@lang('Close')"></button>
                        <div class="modal-heading modal-heading--active d-none">
                            <h6 class="modal-heading__title">@lang('Scan QR Code')</h6>
                            <p class="modal-heading__desc">@lang('Scan this code to activate your eSIM')</p>
                            <img src="" class="modalQr img-fluid esim-qr-img" alt="QR Code">
                        </div>

                        <div class="modal-heading modal-heading--pending d-none">
                            <h6 class="modal-heading__title">@lang('Pending QR Code')</h6>
                            <p class="modal-heading__desc qrWaiting">@lang('Your eSIM is still pending for activation. Please wait.')</p>
                            <img src="{{ asset(activeTemplate(true) . 'images/icon/pending-plan-2.png') }}" class="pending-img" alt="QR Code">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    @endif
@endsection

@if (Route::is('user.esim.active'))
    @push('script')
        <script>
            "use strict";
            (function($) {
                $('.qrCodeBtn').on('click', function() {
                    let qrCodeImage = $(this).data('qr_code_image');
                    if (qrCodeImage) {
                        $('#qrCodeModal').find('.modal-heading--active').removeClass('d-none');
                        $('.modalQr').attr('src', qrCodeImage).removeClass('d-none');
                        $('#qrCodeModal').modal('show');
                        return;
                    } else {
                        const url = $(this).data('url');
                        $.ajax({
                            url: url,
                            method: 'GET',
                            success: function(res) {
                                $('#qrCodeModal').find('.modal-heading--active, .modal-heading--pending').addClass('d-none');
                                $('.modalQr').attr('src', '').addClass('d-none');
                                if (res.status === 'PENDING') {
                                    $('#qrCodeModal').find('.modal-heading--pending').removeClass('d-none');
                                } else if (res.status === 'ACTIVE') {
                                    $('#qrCodeModal').find('.modal-heading--active').removeClass('d-none');
                                    $('.modalQr').attr('src', res.qr).removeClass('d-none');
                                }
                                $('#qrCodeModal').modal('show');
                            },
                            error: function() {
                                notify('error', `@lang('Something went wrong. Please try again later')`);
                            }
                        });
                    }

                });
            })(jQuery);
        </script>
    @endpush
@endif
