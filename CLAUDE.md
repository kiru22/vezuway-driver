# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Logistics UA-ES is a shipment management system for Ukraine-Spain logistics. It consists of:
- **Backend**: Laravel 12 API with PHP 8.3
- **Frontend**: Flutter 3.27 web/mobile app

## Development Commands

### Docker (recommended)
```bash
make setup          # Initial project setup (build, migrate, seed)
make up-dev         # Start development environment with Adminer
make down           # Stop all containers
make test           # Run backend tests
make shell-backend  # Access backend container shell
make logs-backend   # View backend logs
```

### Backend (inside container or local)
```bash
# Tests
php artisan test                     # Run all tests
php artisan test --filter=SomeTest   # Run specific test

# Code style
./vendor/bin/pint                    # Fix code style with Laravel Pint

# Database
php artisan migrate                  # Run migrations
php artisan migrate:fresh --seed     # Reset DB with seeders

# Cache (after config changes)
php artisan config:clear && php artisan cache:clear
```

### Flutter App
```bash
cd app
flutter pub get              # Install dependencies
flutter analyze              # Run static analysis
flutter test                 # Run tests
flutter run -d chrome        # Run web dev server
flutter build web --release  # Production build
```

## Architecture

### Backend: Modular Laravel Structure

The backend uses a modular architecture in `backend/app/Modules/`:

```
Modules/
├── Auth/           # Authentication (login, register, profile)
├── Packages/       # Package/shipment management
├── Routes/         # Delivery routes management
├── Imports/        # Excel imports for bulk data
└── Notifications/  # Push notifications (Firebase)
```

Each module contains:
- `Controllers/` - HTTP request handlers
- `Models/` - Eloquent models
- `Requests/` - Form request validation
- `Resources/` - API response transformers
- `Services/` - Business logic

Shared code lives in `backend/app/Shared/`:
- `Enums/` - PackageStatus, RouteStatus, ImportStatus
- `Traits/` - Reusable model traits
- `Services/` - Cross-module services

API routes are versioned under `/api/v1/` (see `routes/api.php`).

### Frontend: Feature-based Flutter Architecture

Flutter app uses Riverpod for state management in `app/lib/`:

```
lib/
├── core/           # App-wide config, services, theme
├── features/       # Feature modules (auth, packages, routes, etc.)
├── shared/         # Reusable widgets, models, providers
├── app.dart        # Router configuration (go_router)
└── main.dart       # Entry point
```

Each feature follows the pattern:
- `domain/` - Providers, models, repositories
- `presentation/` - Screens and widgets

### Key Dependencies

**Backend:**
- `spatie/laravel-permission` - Role-based access control
- `spatie/laravel-medialibrary` - File/media handling
- `laravel/sanctum` - API authentication
- `maatwebsite/excel` - Excel import/export
- `kreait/laravel-firebase` - Push notifications

**Frontend:**
- `flutter_riverpod` - State management
- `go_router` - Navigation/routing
- `dio` - HTTP client
- `hive_flutter` - Local storage
- `flutter_form_builder` - Form handling

## Services

| Service | Dev Port | Container |
|---------|----------|-----------|
| Backend API | 8000 | logistics-backend |
| Frontend | 3000 | logistics-frontend |
| PostgreSQL | 5432 | logistics-db |
| Redis | 6379 | logistics-redis |
| Adminer | 8080 | logistics-adminer (dev only) |

## Development Notes

### Flutter Local (Recomendado para desarrollo)
Para desarrollo activo con hot reload instantáneo, ejecutar Flutter localmente:

```bash
make frontend-local   # Detiene contenedor Docker y ejecuta Flutter local
```

O manualmente:
```bash
docker stop logistics-frontend
cd app && flutter run -d chrome --web-port=3000
```

- Presionar `r` para hot reload (cambios de UI)
- Presionar `R` para hot restart (cambios estructurales)
- Los cambios se aplican instantáneamente sin reiniciar

### Flutter en Docker (Para CI/CD o testing)
- Usar `make up-dev` para iniciar todos los servicios incluyendo frontend en Docker
- Hot reload no es automático en Docker - requiere `docker restart logistics-frontend`
