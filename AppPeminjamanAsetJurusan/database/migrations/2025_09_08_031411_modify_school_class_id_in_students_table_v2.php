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
        Schema::table('students', function (Blueprint $table) {
            // Drop the foreign key
            $table->dropForeign(['school_class_id']);
            
            // Change the column to be nullable
            $table->unsignedBigInteger('school_class_id')->nullable()->change();
            
            // Re-add the foreign key
            $table->foreign('school_class_id')->references('id')->on('school_classes')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('students', function (Blueprint $table) {
            // Drop the foreign key
            $table->dropForeign(['school_class_id']);
            
            // Change the column back to not nullable
            $table->unsignedBigInteger('school_class_id')->nullable(false)->change();
            
            // Re-add the foreign key
            $table->foreign('school_class_id')->references('id')->on('school_classes')->onDelete('cascade');
        });
    }
};