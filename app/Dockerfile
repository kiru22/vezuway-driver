# Build stage
FROM ghcr.io/cirruslabs/flutter:beta AS build

WORKDIR /app

# Build arguments for configuration
ARG API_URL=http://backend/api/v1
ARG GOOGLE_CLIENT_ID

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build for web with environment variables
RUN flutter build web --release \
    --dart-define=API_URL=${API_URL} \
    --dart-define=GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}

# Production stage
FROM nginx:alpine

# Copy custom nginx config
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copy built web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
