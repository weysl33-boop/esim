@if (gs('socialite_credentials')->linkedin->status || gs('socialite_credentials')->facebook->status == Status::ENABLE || gs('socialite_credentials')->google->status == Status::ENABLE)
    <div class="sign-in">
        <p class="sign-in__or">
            <span class="or-text"> @lang('Or') </span>
        </p>
    </div>

    <div class="social-auth">
        @if (gs('socialite_credentials')->google->status == Status::ENABLE)
            <a class="social-auth__btn" href="{{ route('user.social.login', 'google') }}">
                <img src="{{ asset(activeTemplate(true) . 'images/icon/google.png') }}" alt="@lang('Google')">
                @lang('Continue with Google')
            </a>
        @endif
        @if (gs('socialite_credentials')->facebook->status == Status::ENABLE)
            <a class="social-auth__btn" href="{{ route('user.social.login', 'facebook') }}">
                <img src="{{ asset(activeTemplate(true) . 'images/icon/facebook.png') }}" alt="@lang('Facebook')">
                @lang('Continue with Facebook')
            </a>
        @endif
        @if (gs('socialite_credentials')->linkedin->status == Status::ENABLE)
            <a class="social-auth__btn" href="{{ route('user.social.login', 'linkedin') }}">
                <img src="{{ asset(activeTemplate(true) . 'images/icon/linkedin.png') }}" alt="@lang('Linkedin')">
                @lang('Continue with Linkedin')
            </a>
        @endif
    </div>
@endif
