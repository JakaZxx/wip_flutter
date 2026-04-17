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
            $table->string('email')->unique()->nullable()->after('name');
            $table->string('password')->nullable()->after('email');
            $table->string('role')->default('students')->after('password');
            $table->string('jurusan')->nullable()->after('role');
            $table->string('nis')->nullable()->after('jurusan');
            $table->string('approval_status')->default('approved')->after('nis');
            $table->string('profile_picture')->nullable()->after('approval_status');
            $table->timestamp('email_verified_at')->nullable()->after('profile_picture');
            $table->rememberToken()->after('email_verified_at');
            $table->timestamp('last_seen_notifications')->nullable()->after('remember_token');
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
            $table->dropColumn([
                'email', 'password', 'role', 'jurusan', 'nis', 
                'approval_status', 'profile_picture', 'email_verified_at', 
                'remember_token', 'last_seen_notifications'
            ]);
        });
    }
};
