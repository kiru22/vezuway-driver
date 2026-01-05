# Build stage
FROM ghcr.io/cirruslabs/flutter:3.27.2 AS build

WORKDIR /app

# Build argument for API URL
ARG API_URL=http://backend/api/v1

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build for web with API URL
RUN flutter build web --release --web-renderer html --dart-define=API_URL=${API_URL}

# Production stage
FROM nginx:alpine

# Copy custom nginx config
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copy built web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
