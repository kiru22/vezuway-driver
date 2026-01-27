<?php

namespace App\Providers;

use App\Modules\Contacts\Models\Contact;
use App\Modules\Contacts\Policies\ContactPolicy;
use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Policies\PackagePolicy;
use App\Modules\Routes\Models\Route;
use App\Modules\Routes\Policies\RoutePolicy;
use App\Modules\Trips\Models\Trip;
use App\Modules\Trips\Policies\TripPolicy;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        Gate::policy(Contact::class, ContactPolicy::class);
        Gate::policy(Package::class, PackagePolicy::class);
        Gate::policy(Route::class, RoutePolicy::class);
        Gate::policy(Trip::class, TripPolicy::class);
    }
}
