<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddReturnFieldsToBorrowingsTable extends Migration
{
    public function up()
    {
        Schema::table('borrowings', function (Blueprint $table) {
            if (!Schema::hasColumn('borrowings', 'return_condition')) {
                $table->enum('return_condition', ['Baik', 'Rusak'])->nullable()->after('status');
            }
            if (!Schema::hasColumn('borrowings', 'return_photo')) {
                $table->string('return_photo')->nullable()->after('return_condition');
            }
        });
    }

    public function down()
    {
        Schema::table('borrowings', function (Blueprint $table) {
            if (Schema::hasColumn('borrowings', 'return_photo')) {
                $table->dropColumn('return_photo');
            }
            if (Schema::hasColumn('borrowings', 'return_condition')) {
                $table->dropColumn('return_condition');
            }
        });
    }
}
