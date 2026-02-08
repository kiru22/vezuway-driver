<?php

namespace App\Console\Commands;

use App\Modules\Trips\Models\Trip;
use App\Shared\Enums\TripStatus;
use Illuminate\Console\Command;

class SyncTripStatuses extends Command
{
    protected $signature = 'trips:sync-statuses';

    protected $description = 'Auto-transition planned trips with past departure date to in_progress';

    public function handle(): int
    {
        $updated = Trip::where('status', TripStatus::PLANNED->value)
            ->where('departure_date', '<=', now()->toDateString())
            ->update(['status' => TripStatus::IN_PROGRESS->value]);

        $this->info("Transitioned {$updated} trips from planned to in_progress.");

        return self::SUCCESS;
    }
}
