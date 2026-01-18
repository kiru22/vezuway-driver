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
| Backend API | 8001 | logistics-backend |
| Frontend | 3002 | logistics-frontend |
| PostgreSQL | 5433 | logistics-db |
| Redis | 6380 | logistics-redis |
| Adminer | 8082 | logistics-adminer (dev only) |

> **Nota**: Los puertos están configurados para no conflictuar con winerim (5432, 6379, 8080).

## Development Notes

### Flutter Local (Recomendado para desarrollo)
Para desarrollo activo con hot reload instantáneo, ejecutar Flutter localmente:

```bash
make frontend-local   # Detiene contenedor Docker y ejecuta Flutter local
```

O manualmente:
```bash
docker stop logistics-frontend
cd app && flutter run -d chrome --web-port=3002
```

- Presionar `r` para hot reload (cambios de UI)
- Presionar `R` para hot restart (cambios estructurales)
- Los cambios se aplican instantáneamente sin reiniciar

### Flutter en Docker (Para CI/CD o testing)
- Usar `make up-dev` para iniciar todos los servicios incluyendo frontend en Docker
- Hot reload no es automático en Docker - requiere `docker restart logistics-frontend`

### Aplicar cambios en configuración de Docker (IMPORTANTE)

Los archivos de configuración (nginx, php, supervisor) se copian durante el **build** de la imagen, NO en runtime.

| Comando | ¿Aplica cambios en configs? |
|---------|----------------------------|
| `docker restart <container>` | ❌ No |
| `docker-compose up -d` | ❌ No |
| `docker-compose build <service>` + `up -d` | ✅ Sí |

**Archivos que requieren rebuild:**
- `backend/docker/nginx/default.conf` - Configuración de nginx (CORS, headers, locations)
- `backend/docker/php/php.ini` - Configuración de PHP
- `backend/docker/supervisor/supervisord.conf` - Procesos supervisados

**Comandos para aplicar cambios:**
```bash
docker-compose build backend && docker-compose up -d backend
```

**Verificar que los cambios se aplicaron:**
```bash
docker exec logistics-backend cat /etc/nginx/http.d/default.conf
```

## Deployment (Dokploy)

Dokploy está desplegado en este mismo servidor para gestionar los despliegues de producción.

### Ubicaciones importantes
- **Logs de build**: `/etc/dokploy/logs/`
  - Frontend: `/etc/dokploy/logs/vezuwaydriver-frontend-q9vie7/`
  - Backend: `/etc/dokploy/logs/vezuwaydriver-backend-*/`
- **Código desplegado**: `/etc/dokploy/applications/`
- **Screenshots**: `/home/ubuntu/screenshots/` - capturas de pantalla del sistema

### Comandos útiles
```bash
# Ver logs del último build del frontend
ls -lt /etc/dokploy/logs/vezuwaydriver-frontend-q9vie7/ | head -5
cat /etc/dokploy/logs/vezuwaydriver-frontend-q9vie7/<archivo-más-reciente>.log

# Ver contenedores de Dokploy
docker ps --filter "name=dokploy"

# Ver última captura de pantalla
ls -t /home/ubuntu/screenshots/ | head -1
```

### Notas de compatibilidad
- El frontend usa Flutter beta (`ghcr.io/cirruslabs/flutter:beta`) porque `flutter_form_builder ^10.2.0` requiere Dart 3.8.0+
- Flutter stable (3.29.x) solo tiene Dart 3.7.x, insuficiente para las dependencias actuales

## Versionado y PWA (IMPORTANTE)

### Regla fundamental para deploys
**SIEMPRE incrementar la versión en `app/pubspec.yaml` antes de cada deploy a producción.**

```yaml
# Formato: version: X.Y.Z+build
version: 1.0.1+2  # Incrementar el último número en cada deploy
```

### Por qué es necesario
iOS Safari tiene dos capas de cache para PWAs:
1. **Storage cache (SSD)** - se actualiza con reload
2. **Memory cache (RAM)** - NO se actualiza con reload

El script en `index.html` detecta cambios de versión comparando `version.json` con localStorage y muestra un banner al usuario indicando que debe cerrar y reabrir la app.

### Archivos relacionados con PWA
- `app/pubspec.yaml` - Versión de la app (genera `version.json`)
- `app/web/index.html` - Script de detección de versión
- `app/docker/nginx.conf` - Headers de cache (SW e index.html sin cache)
- `app/web/manifest.json` - Configuración PWA

### Flujo de deploy
1. Incrementar versión en `pubspec.yaml`
2. Build: `flutter build web --release`
3. Commit y push
4. Dokploy despliega automáticamente
5. Usuarios ven banner "Nueva versión disponible"
6. Al cerrar y reabrir la PWA, ven la versión nueva

## Design System (IMPORTANTE)

**Regla fundamental**: Todo cambio de estilos DEBE reflejarse en el Design System y ser documentado para que elementos posteriores lo implementen.

### Archivos del Design System
```
app/lib/core/theme/
├── app_colors.dart           # Paleta de colores (tokens)
├── app_theme.dart            # Temas, tipografía, geometría, decoraciones
├── app_colors_extension.dart # Extensión semántica para dark/light
└── theme_extensions.dart     # BuildContext extensions
```

### Tokens actuales (Design System v1.3)

**Colores principales:**
- Primary: `#10B981` (emerald-500) → `#0D9488` (teal-600)
- Titanium: `#111827` (dark background)
- Surface: `#F0F1F3` (light background)

**Status Badges:**
- Info: bg `#DBEAFE`, text `#1D4ED8`
- Success: bg `#DCFCE7`, text `#15803D`
- Warning: bg `#FFEDD5`, text `#C2410C`
- Error: bg `#FEE2E2`, text `#B91C1C`

**Geometría:**
- `radiusSm`: 12px (chips, botones pequeños)
- `radiusMd`: 16px (inputs, botones)
- `radiusLg`: 24px (cards)
- `radiusXl`: 32px (modales, bottom sheets)

**Efectos:**
- `shadowSoft`: Sombra suave general
- `shadowColored`: Sombra con glow emerald para CTAs
- `glassDecoration`: Efecto glassmorphism (blur 20px + transparencia)

**Tipografía:** Inter (Google Fonts)

### Workflow para cambios de estilo
1. Definir el nuevo token/decoración en `app_theme.dart` o `app_colors.dart`
2. Documentar el uso en este archivo (CLAUDE.md)
3. Implementar usando el token, NO valores hardcodeados
4. Verificar con `flutter analyze`

## Convención de IDs (UUIDs)

**Regla**: Todas las entidades usan UUID v4 como identificador primario.

### Backend

- Todos los modelos usan el trait `App\Shared\Traits\HasUuid`
- Las migraciones usan `$table->uuid('id')->primary()` en lugar de `$table->id()`
- Foreign keys usan `$table->foreignUuid('field_id')`
- Los scopes que reciben IDs usan `string` en lugar de `int`

### Frontend

- Los IDs son siempre `String` (nunca `int`)
- No usar `int.parse()` para IDs en rutas
- En `fromJson`, usar `.toString()` para convertir IDs: `json['id'].toString()`
- En `FutureProvider.family`, el tipo del parámetro es `String`

### Ejemplo de nuevo modelo

**Laravel Model:**
```php
<?php

namespace App\Modules\Example\Models;

use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;

class Example extends Model
{
    use HasUuid;
}
```

**Migración:**
```php
Schema::create('examples', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('user_id')->constrained()->cascadeOnDelete();
    $table->timestamps();
});
```

**Flutter Model:**
```dart
class ExampleModel {
  final String id;
  final String userId;

  ExampleModel({required this.id, required this.userId});

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
    );
  }
}
```

**Flutter Provider:**
```dart
final exampleDetailProvider =
    FutureProvider.family<ExampleModel, String>((ref, id) async {
  final repository = ref.read(exampleRepositoryProvider);
  return repository.getExample(id);
});
```

**Flutter Router:**
```dart
GoRoute(
  path: '/examples/:id',
  pageBuilder: (context, state) {
    final id = state.pathParameters['id']!; // String, no int.parse()
    return MaterialPage(child: ExampleScreen(id: id));
  },
),
```

## OCR - Lista de Ciudades

El servicio OCR detecta nombres de ciudades en imágenes escaneadas. La lista de ciudades está en configuración, no en código.

**Archivo de configuración:** `backend/config/ocr.php`

### Añadir nuevas ciudades

Para añadir una ciudad, editar `backend/config/ocr.php`:

```php
return [
    'cities' => [
        // Formato: nombre canónico, español, ucraniano, código país
        ['name' => 'CityName', 'nameEs' => 'NombreES', 'nameUk' => 'НазваUK', 'country' => 'XX'],
        // ... más ciudades
    ],
];
```

**Campos requeridos:**
- `name`: Nombre canónico (inglés/local) - se usa como identificador
- `nameEs`: Nombre en español - para detección OCR
- `nameUk`: Nombre en ucraniano - para detección OCR
- `country`: Código ISO de país (`ES`, `UA`, `PL`)

Después de añadir ciudades, limpiar caché:
```bash
php artisan config:clear
```
