#!/bin/sh
set -e

echo "🚀 Starting deployment tasks..."

# Wait for database to be ready
echo "⏳ Waiting for database..."
max_tries=30
counter=0
until php artisan db:monitor --databases=pgsql > /dev/null 2>&1 || [ $counter -eq $max_tries ]; do
    counter=$((counter + 1))
    echo "Attempt $counter/$max_tries..."
    sleep 2
done

if [ $counter -eq $max_tries ]; then
    echo "⚠️ Database not ready, continuing anyway..."
fi

# Run migrations
echo "📦 Running migrations..."
php artisan migrate --force

# Clear and rebuild caches
echo "🧹 Clearing caches..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

echo "🔧 Building caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage link (force recreate to ensure it exists)
echo "🔗 Creating storage link..."
rm -f /var/www/html/public/storage
php artisan storage:link --force

# Set permissions
echo "🔐 Setting permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "✅ Deployment tasks completed!"

# Start supervisor (runs nginx + php-fpm + queue workers)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
