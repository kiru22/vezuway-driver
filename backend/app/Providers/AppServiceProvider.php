<?php

namespace App\Providers;

use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Policies\PackagePolicy;
use App\Modules\Routes\Models\Route;
use App\Modules\Routes\Policies\RoutePolicy;
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
        Gate::policy(Package::class, PackagePolicy::class);
        Gate::policy(Route::class, RoutePolicy::class);
    }
}
