<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('borrowings', function (Blueprint $table) {
            $table->dropForeign(['officer_id']); // kalau ada relasi foreign key
            $table->dropColumn('officer_id');
        });
    }

    public function down(): void
    {
        Schema::table('borrowings', function (Blueprint $table) {
            if (!Schema::hasColumn('borrowings', 'officer_id')) {
                $table->unsignedBigInteger('officer_id')->nullable();

                // kalau sebelumnya ada relasi foreign key
                $table->foreign('officer_id')->references('id')->on('officers')->onDelete('cascade');
            }
        });
    }
};
