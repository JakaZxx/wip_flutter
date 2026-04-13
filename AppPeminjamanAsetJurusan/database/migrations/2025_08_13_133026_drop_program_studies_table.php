<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Cek kalau kolom program_id ada, hapus FK & kolomnya dulu
        if (Schema::hasColumn('students', 'program_id')) {
            Schema::table('students', function (Blueprint $table) {
                $table->dropForeign(['program_id']);
                $table->dropColumn('program_id');
            });
        }

        // Setelah FK aman dihapus, baru drop tabel program_studies
        Schema::dropIfExists('program_studies');
    }

    public function down(): void
    {
        
    }
};
