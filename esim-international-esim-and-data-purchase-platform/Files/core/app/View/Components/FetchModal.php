<?php

namespace App\View\Components;

use App\Models\Country;
use App\Models\EsimProvider;
use Illuminate\View\Component;

class FetchModal extends Component
{
    public $esimProviders;
    public $totalCountry;
    public function __construct()
    {
        $this->totalCountry  = Country::count();
        $this->esimProviders = EsimProvider::active()->get();
    }

    public function render()
    {
        return view('components.fetch-modal');
    }
}
