<?php

use App\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        if ($this->isFreshMigration()) {
            $path = database_path('seeds/ecommerceadvlara.sql');

            if (File::exists($path)) {
                $sql = File::get($path);

                DB::unprepared($sql);

                $this->command->info("Database seeded successfully from SQL file.");
            } else {
                $this->command->error("SQL file not found: " . $path);
            }
        } else {
            $this->command->info("Migrations have already been run. Skipping SQL file execution.");
        }
    }

    protected function isFreshMigration()
    {
        return User::all()->count() == 0;
    }
}
