@push('modal')
<div id="coverageAreaModal" class="modal custom--modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">@lang('Coverage Area')</h5>
                <span type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <i class="las la-times"></i>
                </span>
            </div>
            <div class="modal-body">
                <div class="area-plan">
                    <div class="area-plan__header">
                        <div class="input-group input--group">
                            <input type="text" class="form-control form--control searchInput" placeholder="@lang('Search...')">
                            <span class="input-group-text"><i class="las la-search"></i></span>
                        </div>
                    </div>
                    <div class="area-plan__body">
                        <ul class="list-group list-group--coverage">
                            @if (isset($coverageCountries))
                                @include('Template::partials.coverage_area_list', ['coverageCountries' => $coverageCountries])
                            @endif
                        </ul>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn--dark btn--xsm" data-bs-dismiss="modal">@lang('Close')</button>
            </div>
        </div>
    </div>
</div>
@endpush

@push('script')
    <script>
        (function($) {
            'use strict';
            $('.searchInput').on('keyup', function() {
                let search = $(this).val().toLowerCase();
                let matchCount = 0;

                $('.list-group--coverage li').not('.no-data').each(function() {
                    let country = $(this).find('.country-name').text().toLowerCase();
                    if (search === '' || country.indexOf(search) !== -1) {
                        $(this).removeClass('d-none');
                        matchCount++;
                    } else {
                        $(this).addClass('d-none');
                    }
                });

                if (matchCount === 0) {
                    $('.list-group--coverage .no-data').removeClass('d-none');
                } else {
                    $('.list-group--coverage .no-data').addClass('d-none');
                }
            });

            $('#coverageAreaModal').on('shown.bs.modal', function() {
                $(this).find('.searchInput').trigger('focus');
            });
        })(jQuery);
    </script>
@endpush
