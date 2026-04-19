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
        $user = auth()->user();
        $userJurusan = strtolower($user->jurusan);

        // Ambil input dari search bar & filter dropdown
        $search = $request->input('search');
        $level = $request->input('level');
        $program_study = $request->input('program_study');

        // Query dasar
        $query = SchoolClass::query();

        // Mandat: Officer hanya bisa melihat jurusan sendiri
        $query->where(function($q) use ($userJurusan) {
            $q->where('program_study', 'like', "%{$userJurusan}%");
            if ($userJurusan == 'rpl') $q->orWhere('program_study', 'like', '%Rekayasa Perangkat Lunak%');
            if ($userJurusan == 'tkj') $q->orWhere('program_study', 'like', '%Teknik Komputer Jaringan%');
            if ($userJurusan == 'dkv') $q->orWhere('program_study', 'like', '%Desain Komunikasi Visual%');
            if ($userJurusan == 'toi') $q->orWhere('program_study', 'like', '%Teknik Otomasi Industri%');
            if ($userJurusan == 'titl') $q->orWhere('program_study', 'like', '%Teknik Instalasi Tenaga Listrik%');
            if ($userJurusan == 'tav') $q->orWhere('program_study', 'like', '%Teknik Audio Video%');
        });

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
        
        $programStudyListQuery = SchoolClass::select('program_study')->distinct();
        $programStudyListQuery->where(function($q) use ($userJurusan) {
             $q->where('program_study', 'like', "%{$userJurusan}%");
             if ($userJurusan == 'rpl') $q->orWhere('program_study', 'like', '%Rekayasa Perangkat Lunak%');
             if ($userJurusan == 'tkj') $q->orWhere('program_study', 'like', '%Teknik Komputer Jaringan%');
             if ($userJurusan == 'dkv') $q->orWhere('program_study', 'like', '%Desain Komunikasi Visual%');
             if ($userJurusan == 'toi') $q->orWhere('program_study', 'like', '%Teknik Otomasi Industri%');
             if ($userJurusan == 'titl') $q->orWhere('program_study', 'like', '%Teknik Instalasi Tenaga Listrik%');
             if ($userJurusan == 'tav') $q->orWhere('program_study', 'like', '%Teknik Audio Video%');
        });
        $programStudyList = $programStudyListQuery->pluck('program_study');

        return view('officers.classes.index', compact('classes', 'levelList', 'programStudyList'));
    }

    private function isDepartmentMatch($programStudy, $userJurusan)
    {
        $programStudy = strtolower($programStudy);
        $userJurusan = strtolower($userJurusan);
        
        if (str_contains($programStudy, $userJurusan)) return true;
        if ($userJurusan == 'rpl' && str_contains($programStudy, 'rekayasa perangkat lunak')) return true;
        if ($userJurusan == 'tkj' && str_contains($programStudy, 'teknik komputer jaringan')) return true;
        if ($userJurusan == 'dkv' && str_contains($programStudy, 'desain komunikasi visual')) return true;
        if ($userJurusan == 'toi' && str_contains($programStudy, 'teknik otomasi industri')) return true;
        if ($userJurusan == 'titl' && str_contains($programStudy, 'teknik instalasi tenaga listrik')) return true;
        if ($userJurusan == 'tav' && str_contains($programStudy, 'teknik audio video')) return true;
        
        return false;
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
        $user = auth()->user();
        $data = $request->validated();

        // Validasi: Officer hanya bisa menambah kelas untuk jurusan sendiri
        if (!$this->isDepartmentMatch($data['program_study'], $user->jurusan)) {
            return redirect()->back()->withErrors(['program_study' => 'Anda hanya diperbolehkan menambah kelas untuk jurusan ' . strtoupper($user->jurusan)])->withInput();
        }

        SchoolClass::create($data);
        
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
        $user = auth()->user();

        if (!$this->isDepartmentMatch($schoolClass->program_study, $user->jurusan)) {
            abort(403, 'Unauthorized action.');
        }

        return view('officers.classes.edit', compact('schoolClass'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(StoreSchoolClassRequest $request, SchoolClass $schoolClass)
    {
        $user = auth()->user();

        if (!$this->isDepartmentMatch($schoolClass->program_study, $user->jurusan)) {
            abort(403, 'Unauthorized action.');
        }

        $schoolClass->update($request->validated());
        
        return redirect()->route('officers.classes.index')
            ->with('success', 'Data kelas berhasil diperbarui.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(SchoolClass $schoolClass)
    {
        $user = auth()->user();

        if (!$this->isDepartmentMatch($schoolClass->program_study, $user->jurusan)) {
            abort(403, 'Unauthorized action.');
        }

        $schoolClass->delete();
        
        return redirect()->route('officers.classes.index')
            ->with('success', 'Data kelas berhasil dihapus.');
    }
}
