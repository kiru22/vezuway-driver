<?php

namespace App\Console\Commands;

use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Services\TrackingCodeService;
use Illuminate\Console\Command;

class BackfillPublicIds extends Command
{
    protected $signature = 'packages:backfill-public-ids';

    protected $description = 'Generate public_id for existing packages that don\'t have one';

    public function handle(TrackingCodeService $service): int
    {
        $count = Package::whereNull('public_id')->count();

        if ($count === 0) {
            $this->info('All packages already have a public_id.');

            return self::SUCCESS;
        }

        $this->info("Found {$count} packages without public_id. Generating...");

        $bar = $this->output->createProgressBar($count);
        $bar->start();

        Package::whereNull('public_id')
            ->chunkById(100, function ($packages) use ($service, $bar) {
                foreach ($packages as $package) {
                    $package->update([
                        'public_id' => $service->generatePublicId(),
                    ]);
                    $bar->advance();
                }
            });

        $bar->finish();
        $this->newLine();
        $this->info("Done! Generated public_id for {$count} packages.");

        return self::SUCCESS;
    }
}
