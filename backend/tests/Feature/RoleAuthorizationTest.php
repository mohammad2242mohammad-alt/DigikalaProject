<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Tests\TestCase;

class RoleAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_roles_are_strictly_separated(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $seller = User::factory()->create(['role' => 'seller']);
        $buyer = User::factory()->create(['role' => 'buyer']);

        $this->assertTrue($admin->isAdmin());
        $this->assertFalse($admin->isSeller());
        $this->assertFalse($admin->isBuyer());

        $this->assertFalse($seller->isAdmin());
        $this->assertTrue($seller->isSeller());
        $this->assertFalse($seller->isBuyer());

        $this->assertFalse($buyer->isAdmin());
        $this->assertFalse($buyer->isSeller());
        $this->assertTrue($buyer->isBuyer());

        $this->assertTrue(Gate::forUser($admin)->allows('admin'));
        $this->assertFalse(Gate::forUser($admin)->allows('seller'));
        $this->assertFalse(Gate::forUser($seller)->allows('admin'));
        $this->assertTrue(Gate::forUser($seller)->allows('seller'));
        $this->assertFalse(Gate::forUser($buyer)->allows('admin'));
        $this->assertFalse(Gate::forUser($buyer)->allows('seller'));
    }
}
