<div id="fetchModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"></h5>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <i class="las la-times"></i>
                </button>
            </div>
            <form method="POST">
                @csrf
                <div class="modal-body">
                    <div class="form-group">
                        <label>@lang('eSIM Provider')</label>
                        <select name="esim_provider_id" class="form-control" required>
                            <option value="" selected disabled>@lang('Select One')</option>
                            @foreach ($esimProviders as $esimProvider)
                                <option value="{{ $esimProvider->id }}" @if (request()->routeIs('admin.plan.*')) data-slug="{{ $esimProvider->slug }}" @endif>{{ __($esimProvider->provider) }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn h-45 w-100 btn--primary">@lang('Submit')</button>
                </div>
            </form>
        </div>
    </div>
</div>

@push('script')
    <script>
        (function($) {
            "use strict";
            const modal = $('#fetchModal');
            $(document).on('click', '.fetchBtn', function() {
                let data = $(this).data();
                modal.find('.modal-title').text(data.title);
                modal.find('form').attr('action', `${data.action}`);
                modal.modal('show');
            });

            modal.find('form').on('submit', function(e) {
                modal.find('.btn--primary').attr('disabled', true);
            });
        })(jQuery);
    </script>
@endpush
