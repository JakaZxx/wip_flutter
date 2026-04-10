<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AssetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Pastikan true biar validasi jalan
    }

    public function rules(): array
    {
        // Get the commodity ID from the route if it exists (for update operations)
        $commodityId = $this->route('commodity') ?? $this->route('id');

        return [
            'name' => 'required|string|max:255',
            'stock' => 'required|integer|min:0',
            'code' => [
                'nullable',
                'integer',
                Rule::unique('commodities', 'code')->ignore($commodityId)
            ],
            'lokasi' => 'required|string|max:255', // New validation rule for Location
            'jurusan' => 'required|string|max:255', // New validation rule for Department
            'merk' => 'nullable|string|max:255',
            'harga_satuan' => 'nullable|integer|min:0',
            'sumber' => 'nullable|string|max:255',
            'tahun' => 'nullable|integer|min:1900|max:' . (date('Y') + 10),
            'deskripsi' => 'nullable|string|max:1000',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama barang wajib diisi.',
            'stock.required' => 'Stok wajib diisi.',
            'stock.integer' => 'Stok harus berupa angka.',
            'stock.min' => 'Stok tidak boleh negatif.',
            'code.unique' => 'Kode barang sudah digunakan.',
            'lokasi.required' => 'Lokasi barang wajib diisi.',
            'jurusan.required' => 'Jurusan barang wajib diisi.',
        ];
    }
}
