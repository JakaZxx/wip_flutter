<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;

class UpdateUserJurusan extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'user:update-jurusan {userId} {jurusan}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update jurusan field for a user by user ID';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $userId = $this->argument('userId');
        $jurusan = strtolower(trim($this->argument('jurusan')));

        $user = User::find($userId);

        if (!$user) {
            $this->error("User with ID {$userId} not found.");
            return 1;
        }

        $user->jurusan = $jurusan;
        $user->save();

        $this->info("Updated user ID {$userId} jurusan to '{$jurusan}'.");
        return 0;
    }
}
