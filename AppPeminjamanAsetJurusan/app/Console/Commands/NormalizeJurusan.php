<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class NormalizeJurusan extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'normalize:jurusan';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Normalize jurusan values in users and commodities tables to lowercase and trimmed';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Normalizing jurusan values in users table...');
        DB::table('users')->whereNotNull('jurusan')->chunkById(100, function ($users) {
            foreach ($users as $user) {
                $normalized = strtolower(trim($user->jurusan));
                if ($user->jurusan !== $normalized) {
                    DB::table('users')->where('id', $user->id)->update(['jurusan' => $normalized]);
                    $this->info("Updated user ID {$user->id} jurusan to '{$normalized}'");
                }
            }
        });

        $this->info('Normalizing jurusan values in commodities table...');
        DB::table('commodities')->whereNotNull('jurusan')->chunkById(100, function ($commodities) {
            foreach ($commodities as $commodity) {
                $normalized = strtolower(trim($commodity->jurusan));
                if ($commodity->jurusan !== $normalized) {
                    DB::table('commodities')->where('id', $commodity->id)->update(['jurusan' => $normalized]);
                    $this->info("Updated commodity ID {$commodity->id} jurusan to '{$normalized}'");
                }
            }
        });

        $this->info('Normalization complete.');
        return 0;
    }
}
