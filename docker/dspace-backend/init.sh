#!/bin/bash
set -e

echo "🚀 Starting DSpace 9 Backend"
echo "============================"

# Function to wait for service
wait_for_service() {
    local service_name=$1
    local host=$2
    local port=$3
    local max_attempts=30
    local attempt=0
    
    echo "⏳ Waiting for $service_name..."
    while [ $attempt -lt $max_attempts ]; do
        if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
            echo "✅ $service_name is ready!"
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
    done

# Wait for Solr to be ready
echo "Waiting for Solr..."
while ! nc -z dspace-solr 8983; do
  sleep 2
done

echo "Starting DSpace backend..."

# Configure CORS for frontend communication
export DSPACE_CORS_ALLOWED_ORIGINS="http://localhost:4000,http://dspace-frontend:4000"
export DSPACE_CORS_ALLOWED_METHODS="GET,POST,PUT,DELETE,OPTIONS"
export DSPACE_CORS_ALLOWED_HEADERS="*"

# One-time database initialization (if needed)
if [ ! -f /dspace/.db_initialized ]; then
    echo "🗃️ Initializing database..."
    /dspace/bin/dspace database migrate
    
    echo "👤 Creating administrator..."
    /dspace/bin/dspace create-administrator \
        -e "$ADMIN_EMAIL" \
        -f "DSpace" \
        -l "Administrator" \
        -p "$ADMIN_PASSWORD" \
        -c "en" || echo "⚠️ Administrator may already exist"
    
    echo "🔍 Building search index..."
    /dspace/bin/dspace index-discovery -b
    
    touch /dspace/.db_initialized
    echo "✅ Database initialization complete"
fi

echo "🌐 Starting DSpace Spring Boot application..."
echo "Available at: http://localhost:8080/server"

# Start DSpace
exec java $JAVA_OPTS \
    -Ddspace.dir="/dspace" \
    -Dlogging.config="/dspace/config/log4j2.xml" \
    -Dspring.profiles.active="$SPRING_PROFILES_ACTIVE" \
    -jar "/dspace/webapps/server-boot.jar"


