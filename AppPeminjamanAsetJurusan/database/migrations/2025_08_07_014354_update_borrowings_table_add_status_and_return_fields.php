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
        {
            Schema::table('borrowings', function (Blueprint $table) {
                $table->enum('status', ['pending', 'approved', 'rejected', 'returned'])
                    ->default('pending')
                    ->after('return_date');

                $table->unsignedBigInteger('returned_by')->nullable()->after('status');
                $table->text('return_condition')->nullable()->after('returned_by');

                // Foreign key ke officers (jika returned_by dipakai sebagai petugas)
                $table->foreign('returned_by')->references('id')->on('officers')->onDelete('set null');
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // Drop foreign key if it exists
        DB::statement("ALTER TABLE borrowings DROP FOREIGN KEY IF EXISTS borrowings_returned_by_foreign");

        Schema::table('borrowings', function (Blueprint $table) {
            // Check if columns exist before dropping to avoid errors
            if (Schema::hasColumn('borrowings', 'status')) {
                $table->dropColumn('status');
            }
            if (Schema::hasColumn('borrowings', 'returned_by')) {
                $table->dropColumn('returned_by');
            }
            if (Schema::hasColumn('borrowings', 'return_condition')) {
                $table->dropColumn('return_condition');
            }
        });
    }
};
