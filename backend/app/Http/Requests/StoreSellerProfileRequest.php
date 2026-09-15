<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSellerProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSeller() === true;
    }

    public function rules(): array
    {
        return [
            'store_name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:5000'],
            'logo' => ['nullable', 'string', 'max:2048'],
        ];
    }
}
