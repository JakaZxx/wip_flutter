<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('nis')->nullable()->unique()->after('email');
            $table->enum('approval_status', ['pending', 'approved', 'rejected'])->default('pending')->after('role');
            $table->timestamp('password_changed_at')->nullable()->after('password');
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('nis');
            $table->dropColumn('approval_status');
            $table->dropColumn('password_changed_at');
        });
    }
};
