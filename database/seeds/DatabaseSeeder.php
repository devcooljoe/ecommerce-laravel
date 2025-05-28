<?php

use App\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Schema;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        $path = database_path('seeds/ecommerceadvlara.sql');

        if (File::exists($path)) {
            $sql = File::get($path);

            try {
                if (!Schema::hasTable('migrations')) {
                    DB::unprepared($sql);
                    $this->command->info("Database seeded successfully from SQL file.");
                    $this->command->info("Users count: " . DB::table('users')->count());
                } else {
                    $this->command->info("Database has been migrated before");
                }
            } catch (\Exception $e) {
                $this->command->error("Error seeding database: " . $e->getMessage());
            }
        } else {
            $this->command->error("SQL file not found: " . $path);
        }
    }
}
