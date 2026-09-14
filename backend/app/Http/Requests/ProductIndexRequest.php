<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductIndexRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'search' => ['nullable', 'string', 'max:255'],
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'min_price' => ['nullable', 'numeric', 'min:0'],
            'max_price' => ['nullable', 'numeric', 'min:0'],
            'sort' => ['nullable', 'in:latest,price_asc,price_desc,rating,popular'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->filled('min_price') && $this->filled('max_price')) {
            $minPrice = (float) $this->input('min_price');
            $maxPrice = (float) $this->input('max_price');

            if ($maxPrice < $minPrice) {
                $this->merge([
                    'max_price' => null,
                ]);
            }
        }
    }
}
