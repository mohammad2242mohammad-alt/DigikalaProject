<?php

namespace App\Providers;

use App\Models\User;
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
        Gate::define('admin', fn (User $user): bool => $user->isAdmin());
        Gate::define('seller', fn (User $user): bool => $user->isSeller());
        Gate::define('manage-products', fn (User $user): bool => $user->isAdmin());
        Gate::define('manage-categories', fn (User $user): bool => $user->isAdmin());
        Gate::define('manage-orders', fn (User $user): bool => $user->isAdmin());
    }
}
