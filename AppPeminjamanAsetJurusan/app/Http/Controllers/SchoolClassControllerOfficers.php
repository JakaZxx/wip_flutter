<?php

namespace App\Http\Controllers;

use App\Models\SchoolClass;
use Illuminate\Http\Request;
use App\Http\Requests\StoreSchoolClassRequest;

class SchoolClassControllerOfficers extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        // Ambil input dari search bar & filter dropdown
        $search = $request->input('search');
        $level = $request->input('level');
        $program_study = $request->input('program_study');

        // Query dasar
        $query = SchoolClass::query();

        // Jika ada pencarian (nama kelas)
        if (!empty($search)) {
            $query->where('name', 'like', "%{$search}%");
        }

        // Jika filter level dipilih
        if (!empty($level)) {
            $query->where('level', $level);
        }

        // Jika filter program_study dipilih
        if (!empty($program_study)) {
            $query->where('program_study', $program_study);
        }

        // Pagination
        $classes = $query->latest()->paginate(10);

        // Ambil daftar level dan program_study unik untuk dropdown filter
        $levelList = SchoolClass::select('level')->distinct()->pluck('level');
        $programStudyList = SchoolClass::select('program_study')->distinct()->pluck('program_study');

        return view('officers.classes.index', compact('classes', 'levelList', 'programStudyList'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('officers.classes.create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreSchoolClassRequest $request)
    {
        SchoolClass::create($request->validated());
        
        return redirect()->route('officers.classes.index')
            ->with('success', 'Data kelas berhasil ditambahkan.');
    }

    /**
     * Display the specified resource.
     */
    public function show(SchoolClass $schoolClass)
    {
        return view('officers.classes.show', compact('schoolClass'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(SchoolClass $schoolClass)
    {
        return view('officers.classes.edit', compact('schoolClass'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(StoreSchoolClassRequest $request, SchoolClass $schoolClass)
    {
        $schoolClass->update($request->validated());
        
        return redirect()->route('officers.classes.index')
            ->with('success', 'Data kelas berhasil diperbarui.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(SchoolClass $schoolClass)
    {
        $schoolClass->delete();
        
        return redirect()->route('officers.classes.index')
            ->with('success', 'Data kelas berhasil dihapus.');
    }
}
