@extends('admin.layouts.app')
@section('panel')
    <div class="row">
        <div class="col-lg-12">
            <div class="card">
                <div class="card-body p-0">
                    <div class="table-responsive--md  table-responsive">
                        <table class="table table--light style--two">
                            <thead>
                                <tr>
                                    <th>@lang('Name')</th>
                                    <th>@lang('Currency')</th>
                                    <th>@lang('Status')</th>
                                    <th>@lang('Action')</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($esimProviders as $esimProvider)
                                    <tr>
                                        <td>
                                            <a href="{{ $esimProvider->link }}" target="_blank">{{ __($esimProvider->provider) }}</a>
                                        </td>

                                        <td>{{ $esimProvider->currency }}</td>

                                        <td>
                                            @php echo $esimProvider->statusBadge @endphp
                                        </td>

                                        <td>
                                            <div class="button--group">
                                                <button type="button" class="btn btn-sm btn-outline--primary editBtn" data-id="{{ $esimProvider->id }}" data-currency="{{ $esimProvider->currency }}" data-credentials="{{ json_encode($esimProvider->credentials) }}" @if ($esimProvider->slug == 'esimaccess') data-webhook="{{ route('webhook.esimaccess') }}" @endif>
                                                    <i class="las la-pencil-alt"></i>@lang('Edit')
                                                </button>

                                                <button class="btn btn-sm btn-outline--dark helpBtn" data-name="{{ __($esimProvider->provider) }}" data-slug="{{ $esimProvider->slug }}"><i class="las la-info"></i>@lang('Help')</button>

                                                @if ($esimProvider->status == Status::DISABLE)
                                                    <button class="btn btn-sm btn-outline--success confirmationBtn" data-question="@lang('Are you sure to enable this provider?')" data-action="{{ route('admin.provider.esim.status', $esimProvider->id) }}">
                                                        <i class="la la-eye"></i>@lang('Enable')
                                                    </button>
                                                @else
                                                    <button class="btn btn-sm btn-outline--danger confirmationBtn" data-question="@lang('Are you sure to enable this provider?')" data-action="{{ route('admin.provider.esim.status', $esimProvider->id) }}">
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
                        </table><!-- table end -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="editModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">@lang('Update eSIM Provider')</h5>
                    <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                        <i class="las la-times"></i>
                    </button>
                </div>
                <form method="POST">
                    @csrf
                    <div class="modal-body">
                        <div class="form-group">
                            <label>@lang('Currency')</label>
                            <input type="text" name="currency" class="form-control currency" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn--primary h-45 w-100">@lang('Submit')</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div id="helpModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">@lang('Help')</h5>
                    <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                        <i class="las la-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="help-content"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn--dark" data-bs-dismiss="modal">@lang('Close')</button>
                </div>
            </div>
        </div>
    </div>

    <x-confirmation-modal />
@endsection

@push('script')
    <script>
        (function($) {
            'use strict';

            const keyToTitle = (key) => {
                return key
                    .toLowerCase()
                    .replace(/[_-]/g, ' ')
                    .replace(/\b\w/g, char => char.toUpperCase());
            };

            $('.editBtn').on('click', function() {
                let data = $(this).data();
                let modal = $('#editModal');
                let __url = `{{ route('admin.provider.esim.update', ':id') }}`.replace(':id', data.id);

                modal.find('.currency').val(data.currency);
                modal.find('.credentials').remove();
                modal.find('.webhook').remove();

                let html = '';
                $.each(data.credentials, function(index, element) {
                    html += `
                        <div class="form-group credentials">
                            <label for="${index}" class="required">${keyToTitle(index)}</label>
                            <input type="text" name="credentials[${index}]" class="form-control" id="${index}" value="${element}" required>
                        </div>
                    `;
                });

                if (data.webhook) {
                    html += `
                        <div class="form-group webhook">
                            <label for="webhook">@lang('Webhook URL')</label>
                            <div class="input-group">
                                <input type="text" name="webhook" class="form-control" id="webhook" value="${data.webhook}" readonly>
                                <button type="button" class="input-group-text bg--primary border-0 copyBtn">@lang('Copy')</button>
                            </div>
                        </div>
                    `;
                }

                modal.find('.modal-body').append(html);
                modal.find('form').attr('action', __url);
                modal.modal('show');
            });

            $(document).on('click', '.copyBtn', function() {
                let input = $(this).siblings('input');
                input.select();
                document.execCommand('copy');
                notify('success', '@lang('Copied to clipboard')');
            });

            function getDataplansioHelpContent() {
                return `
                <div class="provider-help">
                    <ol>
                        <li>@lang('Visit') <a href="https://dataplans.io" target="_blank">https://dataplans.io</a> @lang('and click') <strong>@lang('Sign Up')</strong>.</li>
                        <li>@lang('Complete the registration process.')</li>
                        <li>@lang('Login to your Dataplans.io account.')</li>
                        <li>@lang('In your dataplans.io dashboard you can see API Key section and a button to "Roll API KEY". Click the button.')</li>
                        <li>@lang('Then copy the "ACCESS TOKEN".')</li>
                        <li>@lang('Paste the credentials into the "Api Key" field and click') <strong>@lang('Save')</strong>.</li>
                    </ol>
                </div>
                `;
            }

            function getAirAloHelpContent() {
                return `
                <div class="provider-help">
                    <ol>
                        <li>@lang('Visit') <a href="https://airalo.com" target="_blank">https://airalo.com</a> @lang('and scroll to the bottom of the page.')</li>
                        <li>@lang('Click on') <strong>@lang('API Partners')</strong> @lang('and click to') <strong>"JOIN US"</strong>@lang('button').</li>
                        <li>@lang('Fill out the application form with your business details and submit it.')</li>
                        <li>@lang('Once approved, Airalo will provide you with access credentials (API Key / Client ID & Secret).')</li>
                        <li>@lang('Login to your reseller dashboard at Airalo after approval.')</li>
                        <li>@lang('Navigate <i>"API Integration"</i> menu and copy the <strong>"API Client ID"</strong> and <strong>"API Client Secret"</strong>.')</li>
                        <li>@lang('Paste these credentials into the corresponding fields in your system and click') <strong>@lang('Save')</strong>.</li>
                    </ol>
                </div>
                `;
            }

            function getEsimSMHelpContent() {
                return `
                    <div class="provider-help">
                        <ol>
                            <li>@lang('Open') <a href="https://esim.sm" target="_blank">https://esim.sm</a> @lang('and click') <strong>@lang('Register')</strong>.</li>
                            <li>@lang('Complete the registration process.')</li>
                            <li>@lang('Login to the esim.sm reseller dashboard.')</li>
                            <li>@lang('Navigate') <em>@lang('Payment') -> @lang('Generate API KEY')</em>.</li>
                            <li>@lang('Copy') <strong>@lang('API KEY')</strong>.</li>
                            <li>@lang('Paste the credentials and click') <strong>@lang('Save')</strong>.</li>
                        </ol>
                    </div>
                    `;
            }

            function getEsimAccessHelpContent() {
                return `
                    <div class="provider-help">
                        <ol>
                            <li>@lang('Go to') <a href="https://esimaccess.com" target="_blank">https://esimaccess.com</a> @lang('and select') <strong>@lang('Join as Partner')</strong>.</li>
                            <li>@lang('Complete the registration process.')</li>
                            <li>@lang('Once completed'), @lang('log in to your EsimAccess dashboard.')</li>
                            <li>@lang('Navigate to') <em>@lang('Developer')</em>.</li>
                            <li>@lang('Copy the') <strong>AccessCode</strong> and <strong>SecretKey</strong></li>
                            <li>@lang('Enter the credentials and click') <strong>@lang('Save')</strong>.</li>
                            <li>@lang('Copy the webhook URL from your admin panel.')</li>
                            <li>@lang('Add the webhook URL to esimacess by navigating') <em>@lang('Developer') → @lang('Webhooks')</em>.</li>
                        </ol>
                    </div>
                    `;
            }

            function getEsimCardHelpContent() {
                return `
                    <div class="provider-help">
                        <ol>
                            <li>@lang('Visit') <a href="https://esimcard.com" target="_blank">https://esimcard.com</a> @lang('and navigate') <em>@lang('Partner With Us') → @lang('eSIM Reseller API')</em></li>
                            <li>@lang('Complete the partnership process.')</li>
                            <li>@lang('Login to the EsimCard partner dashboard.')</li>
                            <li>@lang('If you can successfully login to your panel then enter your email & password and submit the form.')</li>
                        </ol>
                    </div>
                    `;
            }

            $('.helpBtn').on('click', function() {
                let slug = $(this).data('slug');
                let content = '';

                if (slug == 'dataplansio') {
                    content = getDataplansioHelpContent();
                } else if (slug == 'esimaccess') {
                    content = getEsimAccessHelpContent();
                } else if (slug == 'esimsm') {
                    content = getEsimSMHelpContent(slug);
                } else if (slug == 'esimcard') {
                    content = getEsimCardHelpContent();
                } else if (slug == 'airalo') {
                    content = getAirAloHelpContent();
                } else {
                    content = `<p>@lang('No help content available for this provider.')</p>`;
                }

                let modal = $('#helpModal');

                modal.find('.help-content').html(content);
                modal.find('.modal-title').text(`@lang('Integration Guide for') ${$(this).data('name')}`);
                modal.modal('show');
            });
        })(jQuery);
    </script>
@endpush

@push('style')
    <style>
        .provider-help {
            font-size: 14px;
            line-height: 1.6;
        }

        .provider-help ol {
            padding-left: 16px;
            list-style: number;
        }

        .provider-help li {
            margin-bottom: 10px;
        }

        .provider-help a {
            color: #007bff;
            text-decoration: underline;
        }
    </style>
@endpush
