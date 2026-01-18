# Logistics UA-ES - Docker Setup

Sistema de gestion de envios Ucrania-Espana containerizado con Docker.

## Requisitos

- Docker 24.0+
- Docker Compose 2.0+
- Make (opcional, para comandos simplificados)

## Inicio Rapido

### 1. Clonar y configurar

```bash
# Copiar configuracion de ejemplo
cp .env.example .env
cp backend/.env.example backend/.env

# Editar .env con tus valores
```

### 2. Construir e iniciar

```bash
# Con Make
make setup

# Sin Make
docker compose build
docker compose up -d
docker compose exec backend php artisan key:generate
docker compose exec backend php artisan migrate
```

### 3. Acceder a los servicios

| Servicio | URL | Descripcion |
|----------|-----|-------------|
| Frontend | http://localhost:3002 | App Flutter Web |
| Backend API | http://localhost:8001 | Laravel API |
| Adminer | http://localhost:8082 | DB Manager (solo dev) |

## Comandos Docker

### Usando Make

```bash
make build          # Construir imagenes
make up             # Iniciar contenedores (produccion)
make up-dev         # Iniciar con Adminer (desarrollo)
make down           # Detener contenedores
make restart        # Reiniciar todo
make logs           # Ver logs de todos los servicios
make logs-backend   # Ver logs del backend
make logs-frontend  # Ver logs del frontend
make shell-backend  # Shell en contenedor backend
make migrate        # Ejecutar migraciones
make seed           # Ejecutar seeders
make fresh          # Recrear BD con seeders
make test           # Ejecutar tests
make clean          # Limpiar todo (contenedores, volumenes, imagenes)
```

### Sin Make

```bash
# Construir
docker compose build

# Iniciar
docker compose up -d

# Con perfil dev (incluye Adminer)
docker compose --profile dev up -d

# Detener
docker compose down

# Logs
docker compose logs -f
docker compose logs -f backend

# Shell
docker compose exec backend sh

# Laravel commands
docker compose exec backend php artisan migrate
docker compose exec backend php artisan db:seed
docker compose exec backend php artisan tinker
```

## Arquitectura

```
┌─────────────────┐     ┌─────────────────┐
│    Frontend     │────▶│    Backend      │
│  (Flutter Web)  │     │    (Laravel)    │
│   nginx:80      │     │   nginx:80      │
│   port: 3002    │     │   port: 8001    │
└─────────────────┘     └────────┬────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
              ┌─────▼─────┐           ┌───────▼───────┐
              │  Postgres │           │     Redis     │
              │   :5433   │           │     :6380     │
              └───────────┘           └───────────────┘
```

## Configuracion de Produccion

### Variables de entorno importantes

```bash
# .env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:... # Generada con php artisan key:generate
DB_PASSWORD=tu_password_seguro
API_URL=https://api.tudominio.com/api/v1
```

### Con dominio personalizado

1. Actualizar `API_URL` en `.env`
2. Reconstruir frontend: `docker compose build frontend`
3. Configurar reverse proxy (Traefik, Nginx, etc.)

### Ejemplo con Traefik

```yaml
# docker-compose.prod.yml
services:
  frontend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`app.tudominio.com`)"
      - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"

  backend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.tudominio.com`)"
      - "traefik.http.routers.backend.tls.certresolver=letsencrypt"
```

## Desarrollo Local

### Hot reload con volumenes

El archivo `docker-compose.override.yml` monta los directorios locales para desarrollo:

```bash
# Iniciar en modo desarrollo
docker compose up -d

# Los cambios en backend/ y app/ se reflejan automaticamente
```

### Ejecutar tests

```bash
# Backend tests
docker compose exec backend php artisan test

# Con coverage
docker compose exec backend php artisan test --coverage
```

## Troubleshooting

### Error: "No space left on device"

```bash
docker system prune -a --volumes
```

### Error: "Port already in use"

```bash
# Cambiar puertos en .env
BACKEND_PORT=8001
FRONTEND_PORT=3002
```

### Contenedor no inicia

```bash
# Ver logs detallados
docker compose logs -f [servicio]

# Verificar estado
docker compose ps
```

### Resetear base de datos

```bash
docker compose down -v  # Elimina volumenes
docker compose up -d
docker compose exec backend php artisan migrate --seed
```

## Backup y Restore

### Backup de base de datos

```bash
docker compose exec postgres pg_dump -U logistics logistics > backup.sql
```

### Restore

```bash
cat backup.sql | docker compose exec -T postgres psql -U logistics logistics
```
