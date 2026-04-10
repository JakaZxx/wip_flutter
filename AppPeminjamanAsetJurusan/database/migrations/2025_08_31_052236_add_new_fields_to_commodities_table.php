<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('commodities', function (Blueprint $table) {
            $table->string('merk')->nullable()->after('name');
            $table->bigInteger('harga_satuan')->nullable()->after('merk');
            $table->string('sumber')->nullable()->after('harga_satuan');
            $table->year('tahun')->nullable()->after('sumber');
            $table->text('deskripsi')->nullable()->after('tahun');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('commodities', function (Blueprint $table) {
            $table->dropColumn(['merk', 'harga_satuan', 'sumber', 'tahun', 'deskripsi']);
        });
    }
};
