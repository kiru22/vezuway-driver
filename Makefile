.PHONY: help build up down restart logs shell-backend shell-frontend frontend-local migrate seed fresh test clean

# Default target
help:
	@echo "Logistics UA-ES - Docker Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build          Build all Docker images"
	@echo "  up             Start all containers"
	@echo "  up-dev         Start all containers with dev profile (includes Adminer)"
	@echo "  down           Stop all containers"
	@echo "  restart        Restart all containers"
	@echo "  logs           View logs from all containers"
	@echo "  logs-backend   View backend logs"
	@echo "  logs-frontend  View frontend logs"
	@echo "  shell-backend  Open shell in backend container"
	@echo "  shell-frontend Open shell in frontend container"
	@echo "  frontend-local Run Flutter locally with hot reload"
	@echo "  migrate        Run Laravel migrations"
	@echo "  seed           Run Laravel seeders"
	@echo "  fresh          Fresh migration with seed"
	@echo "  test           Run backend tests"
	@echo "  clean          Remove all containers, volumes, and images"
	@echo "  setup          Initial project setup"

# Build all images
build:
	docker compose build

# Start containers (production mode)
up:
	docker compose -f docker-compose.yml up -d

# Start containers (development mode with Adminer)
up-dev:
	docker compose --profile dev up -d

# Stop containers
down:
	docker compose down

# Restart containers
restart: down up

# View all logs
logs:
	docker compose logs -f

# View backend logs
logs-backend:
	docker compose logs -f backend

# View frontend logs
logs-frontend:
	docker compose logs -f frontend

# Shell access
shell-backend:
	docker compose exec backend sh

shell-frontend:
	docker compose exec frontend sh

# Run Flutter locally with hot reload (stop Docker frontend first)
frontend-local:
	@docker stop logistics-frontend 2>/dev/null || true
	cd app && flutter run -d chrome --web-port=3002

# Laravel commands
migrate:
	docker compose exec backend php artisan migrate

seed:
	docker compose exec backend php artisan db:seed

fresh:
	docker compose exec backend php artisan migrate:fresh --seed

# Run tests
test:
	docker compose exec backend php artisan test

# Cache commands
cache-clear:
	docker compose exec backend php artisan cache:clear
	docker compose exec backend php artisan config:clear
	docker compose exec backend php artisan route:clear
	docker compose exec backend php artisan view:clear

cache-warmup:
	docker compose exec backend php artisan config:cache
	docker compose exec backend php artisan route:cache
	docker compose exec backend php artisan view:cache

# Clean everything
clean:
	docker compose down -v --rmi all --remove-orphans
	docker system prune -f

# Initial setup
setup:
	@echo "Setting up Logistics UA-ES..."
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@if [ ! -f backend/.env ]; then cp backend/.env.example backend/.env; fi
	docker compose build
	docker compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 10
	docker compose exec backend php artisan key:generate
	docker compose exec backend php artisan migrate
	@echo ""
	@echo "Setup complete!"
	@echo "Backend API: http://localhost:8001"
	@echo "Frontend:    http://localhost:3002"
	@echo "Adminer:     http://localhost:8082 (run 'make up-dev' first)"
