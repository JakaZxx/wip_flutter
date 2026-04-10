<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSchoolClassRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255|unique:school_classes,name,' . $this->route('school_class'),
            'level' => 'required|in:X,XI,XII',
            'program_study' => 'required|string|max:100',
            'capacity' => 'required|integer|min:1|max:50',
            'description' => 'nullable|string|max:500',
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array
     */
    public function messages()
    {
        return [
            'name.required' => 'Nama kelas wajib diisi.',
            'name.unique' => 'Nama kelas sudah digunakan.',
            'level.required' => 'Tingkat kelas wajib dipilih.',
            'level.in' => 'Tingkat kelas harus salah satu dari: X, XI, atau XII.',
            'program_study.required' => 'Program studi wajib diisi.',
            'program_study.max' => 'Program studi maksimal 100 karakter.',
            'capacity.required' => 'Kapasitas kelas wajib diisi.',
            'capacity.integer' => 'Kapasitas kelas harus berupa angka.',
            'capacity.min' => 'Kapasitas kelas minimal 1 siswa.',
            'capacity.max' => 'Kapasitas kelas maksimal 50 siswa.',
            'description.max' => 'Deskripsi kelas maksimal 500 karakter.',
        ];
    }
}
