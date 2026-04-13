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
        Schema::table('borrowing_items', function (Blueprint $table) {
            $table->string('condition')->nullable();
            $table->text('description')->nullable();
            $table->string('photo_path')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('borrowing_items', function (Blueprint $table) {
            $table->dropColumn(['condition', 'description', 'photo_path']);
        });
    }
};
