#!/bin/sh
set -e

echo "🚀 Starting DSpace Frontend"
echo "============================="

# Configuration
DSPACE_CONFIG_FILE="/app/config/config.yml"

echo "📋 Configuration:"
echo "  UI Host: $DSPACE_UI_HOST"
echo "  UI Port: $DSPACE_UI_PORT"  
echo "  REST Host: $DSPACE_REST_HOST"
echo "  REST Port: $DSPACE_REST_PORT"
echo "  REST Namespace: $DSPACE_REST_NAMESPACE"
echo "  REST SSL: $DSPACE_REST_SSL"

# Function to update configuration with environment variables
update_config() {
    echo "🔧 Updating configuration with environment variables..."
    
    # Create a temporary config file with environment variables applied
    cat > "$DSPACE_CONFIG_FILE" << EOF
# DSpace Angular Docker Configuration (Runtime)
debug: false

ui:
  ssl: ${DSPACE_REST_SSL:-false}
  host: 0.0.0.0
  port: ${DSPACE_UI_PORT:-4000}
  nameSpace: /
  rateLimiter:
    windowMs: 60000
    max: 500
  useProxies: true

rest:
  ssl: ${DSPACE_REST_SSL:-false}
  host: ${DSPACE_REST_HOST:-dspace-backend}
  port: ${DSPACE_REST_PORT:-8080}
  nameSpace: ${DSPACE_REST_NAMESPACE:-/server}

cache:
  msToLive:
    default: 900000
    browse: 300000
    search: 300000

production: true
defaultLanguage: en

languages:
  - code: en
    label: English
    active: true

themes:
  - name: dspace
    enableTheming: true
    headTags: []

submission:
  autosave:
    metadata: []
    timer: 0

browseBy:
  showThumbnails: true
  types:
    - id: title
      metadataField: 'dc.title'
      sortField: 'dc.title'
    - id: author
      metadataField: 'dc.contributor.*'
      sortField: 'dc.contributor.author'
    - id: subject
      metadataField: 'dc.subject.*'
      sortField: 'dc.subject'
    - id: dateissued
      metadataField: 'dc.date.issued'
      sortField: 'dc.date.issued'
EOF
}

# Function to wait for backend service
wait_for_backend() {
    echo "⏳ Waiting for DSpace Backend at $DSPACE_REST_HOST:$DSPACE_REST_PORT..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if timeout 5 sh -c "echo > /dev/tcp/$DSPACE_REST_HOST/$DSPACE_REST_PORT" 2>/dev/null; then
            echo "✅ Backend is ready!"
            return 0
        fi
        echo "  Attempt $((attempt + 1))/$max_attempts - Backend not ready, waiting 10 seconds..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "❌ Backend failed to become ready after $max_attempts attempts"
    echo "⚠️  Continuing anyway - frontend will show errors until backend is available"
}

# Update configuration first
update_config

# Wait for backend (but don't fail if it's not ready)
wait_for_backend || true

# Test backend connectivity
echo "🔍 Testing backend connectivity..."
if curl -f -s "http://$DSPACE_REST_HOST:$DSPACE_REST_PORT/server/api" > /dev/null 2>&1; then
    echo "✅ Backend API is responding"
else
    echo "⚠️  Backend API not responding - check backend service"
fi

echo "🌐 Starting DSpace Frontend server..."
echo "Available at: http://$DSPACE_UI_HOST:$DSPACE_UI_PORT"
echo ""

# Start the DSpace Angular SSR server
exec npm run serve:ssr
