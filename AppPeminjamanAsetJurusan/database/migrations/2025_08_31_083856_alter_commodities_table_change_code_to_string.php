<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up(): void
    {
        Schema::table('commodities', function (Blueprint $table) {
            // Ubah kolom code jadi string nullable
            $table->string('code')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down(): void
    {
        // Handle non-numeric codes by setting them to NULL before changing column type
        DB::statement("UPDATE commodities SET code = NULL WHERE code IS NOT NULL AND code NOT REGEXP '^[0-9]+$'");

        Schema::table('commodities', function (Blueprint $table) {
            // Balikin lagi ke integer, nullable biar nggak bentrok rollback
            $table->integer('code')->nullable()->change();
        });
    }
};
