@extends('Template::layouts.frontend')
@section('content')
    <section class="my-80">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    @php
                        echo $policy->data_values->details;
                    @endphp
                </div>
            </div>
    </section>
@endsection
