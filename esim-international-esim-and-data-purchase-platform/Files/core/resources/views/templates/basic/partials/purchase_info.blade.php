<div class="choose-plan-sidebar__body">
    <ul class="choose-plan-feat mb-4">
        <li class="choose-plan-feat__item">
            <div class="wrapper">
                <i class="las la-globe"></i>
                <span class="label">@lang('Coverage')</span>
            </div>
            <span class="value coverageLink"> -- </span>
        </li>

        <li class="choose-plan-feat__item">
            <div class="wrapper">
                <i class="las la-exchange-alt"></i>
                <span class="label">@lang('Data')</span>
            </div>
            <span class="value dataCapacity"></span>
        </li>

        <li class="choose-plan-feat__item talkTimeWrapper d-none">
            <div class="wrapper">
                <i class="las la-phone"></i>
                <span class="label">@lang('Talk Times')</span>
            </div>
            <span class="value talkTime"></span>
        </li>

        <li class="choose-plan-feat__item smsWrapper d-none">
            <div class="wrapper">
                <i class="las la-sms"></i>
                <span class="label">@lang('SMS')</span>
            </div>
            <span class="value smsQty"></span>
        </li>

        <li class="choose-plan-feat__item">
            <div class="wrapper">
                <i class="las la-calendar"></i>
                <span class="label">@lang('Validity')</span>
            </div>
            <span class="value dataValidity"></span>
        </li>

        <li class="choose-plan-feat__item">
            <div class="wrapper">
                <i class="las la-plus-circle"></i>
                <span class="label">@lang('Topup')</span>
            </div>
            <span class="value rechargeable"></span>
        </li>

        <li class="choose-plan-feat__item">
            <div class="wrapper">
                <i class="las la-exchange-alt"></i>
                <span class="label">@lang('Refundable')</span>
            </div>
            <span class="value refundable"></span>
        </li>
    </ul>

    <ul class="choose-plan-meta">
        <li class="choose-plan-meta__item">
            <span class="label">@lang('Price')</span>
            <span class="value dataPrice"></span>
        </li>
        <li class="choose-plan-meta__item discountWrapper d-none">
            <span class="label">@lang('Discount')(<span class="discountPercentage"></span>)</span>
            <span class="value discount"></span>
        </li>
        <li class="choose-plan-meta__item">
            <span class="label">@lang('Total')</span>
            <span class="value highlighted dataTotalPrice"></span>
        </li>
    </ul>
</div>
<div class="choose-plan-sidebar__footer">
    <button type="submit" class="w-100 btn btn--base">
        @lang('Purchase Now')
    </button>
</div>
