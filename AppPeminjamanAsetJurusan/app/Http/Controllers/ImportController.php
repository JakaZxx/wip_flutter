<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\UsersImport;
use App\Imports\AssetsImport;
use App\Imports\ClassesStudentsImport;
use App\Imports\ClassesImport;
use App\Imports\StudentsImport;

class ImportController extends Controller
{


    public function importUsers(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:xlsx,csv',
        ]);

        try {
            Excel::import(new UsersImport, $request->file('file'));
            return redirect()->back()->with('success', 'Data users berhasil diimpor.');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Gagal mengimpor data users: ' . $e->getMessage());
        }
    }

    public function importAssets(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:xlsx,csv',
        ]);

        try {
            Excel::import(new AssetsImport, $request->file('file'));
            return redirect()->back()->with('success', 'Data aset berhasil diimpor.');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Gagal mengimpor data aset: ' . $e->getMessage());
        }
    }

    public function importClassesStudents(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:xlsx,csv',
        ]);

        try {
            Excel::import(new ClassesStudentsImport, $request->file('file'));
            return redirect()->back()->with('success', 'Data kelas dan siswa berhasil diimpor.');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Gagal mengimpor data kelas dan siswa: ' . $e->getMessage());
        }
    }

    public function importClasses(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:xlsx,csv',
        ]);

        try {
            Excel::import(new ClassesImport, $request->file('file'));
            return redirect()->back()->with('success', 'Data kelas berhasil diimpor.');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Gagal mengimpor data kelas: ' . $e->getMessage());
        }
    }

    public function importStudents(Request $request, $schoolClassId)
    {
        $user = auth()->user();
        $schoolClass = \App\Models\SchoolClass::findOrFail($schoolClassId);

        if ($user->role == 'officers') {
            $userJurusan = strtolower($user->jurusan);
            $classJurusan = strtolower($schoolClass->program_study);
            
            $isMatch = str_contains($classJurusan, $userJurusan);
            if ($userJurusan == 'rpl' && str_contains($classJurusan, 'rekayasa perangkat lunak')) $isMatch = true;
            if ($userJurusan == 'tkj' && str_contains($classJurusan, 'teknik komputer jaringan')) $isMatch = true;
            if ($userJurusan == 'dkv' && str_contains($classJurusan, 'desain komunikasi visual')) $isMatch = true;
            if ($userJurusan == 'toi' && str_contains($classJurusan, 'teknik otomasi industri')) $isMatch = true;
            if ($userJurusan == 'titl' && str_contains($classJurusan, 'teknik instalasi tenaga listrik')) $isMatch = true;
            if ($userJurusan == 'tav' && str_contains($classJurusan, 'teknik audio video')) $isMatch = true;

            if (!$isMatch) {
                abort(403, 'Anda tidak memiliki akses ke kelas ini.');
            }
        }

        $request->validate([
            'file' => 'required|file|mimes:xlsx,csv',
        ]);

        try {
            Excel::import(new StudentsImport($schoolClassId), $request->file('file'));
            return redirect()->back()->with('success', 'Data siswa berhasil diimpor.');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Gagal mengimpor data siswa: ' . $e->getMessage());
        }
    }
}
