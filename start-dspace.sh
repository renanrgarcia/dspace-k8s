#!/bin/bash

# DSpace 9 Docker Setup Script
# This script sets up and starts the complete DSpace environment

set -e

echo "🚀 DSpace 9 Docker Setup"
echo "========================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. You can customize it if needed."
fi

# Check if DSpace source exists
if [ ! -d "dspace-source" ] || [ ! -f "dspace-source/pom.xml" ]; then
    echo "📥 DSpace source not found. Cloning DSpace 9.0..."
    git clone -b dspace-9.0 https://github.com/DSpace/DSpace.git dspace-source
    echo "✅ DSpace source cloned successfully."
fi

# Check if DSpace Angular exists
if [ ! -d "dspace-angular" ] || [ ! -f "dspace-angular/package.json" ]; then
    echo "📥 DSpace Angular not found. Cloning DSpace Angular 9.1..."
    git clone -b dspace-9.1 https://github.com/DSpace/dspace-angular.git dspace-angular
    echo "✅ DSpace Angular cloned successfully."
fi

echo "🧹 Cleaning up any existing containers..."
docker-compose down -v 2>/dev/null || true

echo "🏗️ Building and starting DSpace services..."
echo "This may take 15-20 minutes on first run..."

# Start services in order
docker-compose up -d dspace-db dspace-solr

echo "⏳ Waiting for database and Solr to be ready..."
sleep 30

# Start backend
docker-compose up -d dspace-backend

echo "⏳ Waiting for backend to be ready..."
echo "This can take 10-15 minutes for initial setup..."

# Wait for backend health check
timeout 900 bash -c 'until docker-compose ps | grep dspace-backend | grep -q "healthy"; do sleep 10; echo "Still waiting for backend..."; done' || {
    echo "❌ Backend failed to start within 15 minutes. Check logs with: docker-compose logs dspace-backend"
    exit 1
}

# Start frontend
docker-compose up -d dspace-frontend

echo "⏳ Waiting for frontend to be ready..."
timeout 300 bash -c 'until docker-compose ps | grep dspace-frontend | grep -q "healthy"; do sleep 10; echo "Still waiting for frontend..."; done' || {
    echo "❌ Frontend failed to start within 5 minutes. Check logs with: docker-compose logs dspace-frontend"
    exit 1
}

echo ""
echo "🎉 DSpace is now running!"
echo "========================="
echo "📱 Frontend: http://localhost:4000"
echo "🔧 Backend API: http://localhost:8080/server/api"
echo "🔍 Solr Admin: http://localhost:8983"
echo "🗄️ Database: localhost:5432 (user: dspace, password: dspace)"
echo ""
echo "👤 Default Admin Account:"
echo "   Email: admin@dspace.org"
echo "   Password: admin"
echo ""
echo "📋 Useful Commands:"
echo "   View logs: docker-compose logs -f [service-name]"
echo "   Stop all: docker-compose down"
echo "   Restart: docker-compose restart [service-name]"
echo "   Clean reset: docker-compose down -v && ./start-dspace.sh"
echo ""
echo "🔗 Access the DSpace frontend at: http://localhost:4000"
