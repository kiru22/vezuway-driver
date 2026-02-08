<?php

namespace App\Console\Commands;

use App\Modules\Cities\Services\GeoNamesImportService;
use Illuminate\Console\Command;

class ImportCitiesCommand extends Command
{
    protected $signature = 'cities:import
        {--countries=ES,UA,PL,DE : Comma-separated country codes}
        {--min-population=0 : Minimum population filter}';

    protected $description = 'Import cities from GeoNames data into the cities table';

    public function handle(GeoNamesImportService $service): int
    {
        $countries = array_map('trim', explode(',', $this->option('countries')));
        $minPopulation = (int) $this->option('min-population');

        $this->info('Starting GeoNames import...');
        $this->info('Countries: '.implode(', ', $countries));
        $this->info("Min population: {$minPopulation}");
        $this->newLine();

        $total = $service->import(
            $countries,
            $minPopulation,
            fn (string $msg) => $this->line($msg),
        );

        $this->newLine();
        $this->info("Import complete. Total cities imported: {$total}");

        return self::SUCCESS;
    }
}
