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
        // 1. Create the new pivot table
        Schema::create('borrowing_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('borrowing_id')->constrained()->onDelete('cascade');
            $table->foreignId('commodity_id')->constrained()->onDelete('cascade');
            $table->integer('quantity')->unsigned()->default(1);
            $table->timestamps();
        });

        // 2. Remove old columns from borrowings table
        Schema::table('borrowings', function (Blueprint $table) {
            $table->dropForeign(['commodity_id']);
            $table->dropColumn('commodity_id');
            $table->dropColumn('quantity');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // 1. Re-add columns to borrowings table
        Schema::table('borrowings', function (Blueprint $table) {
            $table->foreignId('commodity_id')->nullable()->after('student_id')->constrained()->onDelete('set null');
            $table->integer('quantity')->default(1)->after('return_date');
        });

        // 2. Drop the pivot table
        Schema::dropIfExists('borrowing_items');
    }
};
