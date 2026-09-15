<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SellerProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isSeller() === true;
    }

    public function rules(): array
    {
        return [
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'min:0'],
            'discount_price' => ['nullable', 'numeric', 'min:0', 'lte:price'],
            'image' => ['nullable', 'string', 'max:2048'],
            'stock' => ['required', 'integer', 'min:0'],
        ];
    }
}
