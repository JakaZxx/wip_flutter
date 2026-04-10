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
    public function up()
    {
        // Add new statuses to the enum
        DB::statement("ALTER TABLE borrowings MODIFY COLUMN status ENUM('pending', 'approved', 'rejected', 'returned', 'partial', 'partially_approved', 'partially_returned') NOT NULL DEFAULT 'pending'");
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // Revert to original enum
        DB::statement("ALTER TABLE borrowings MODIFY COLUMN status ENUM('pending', 'approved', 'rejected', 'returned') NOT NULL DEFAULT 'pending'");
    }
};
