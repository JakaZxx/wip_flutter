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
        Schema::table('borrowings', function (Blueprint $table) {
            // Drop the old foreign key constraint if it exists
            $table->dropForeign('borrowings_returned_by_foreign');

            // Add the new foreign key constraint referencing the users table
            $table->foreign('returned_by')->references('id')->on('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('borrowings', function (Blueprint $table) {
            // Drop the new foreign key constraint
            $table->dropForeign(['returned_by']);

            // Re-add the old foreign key constraint referencing the officers table
            $table->foreign('returned_by')->references('id')->on('officers')->onDelete('set null');
        });
    }
};