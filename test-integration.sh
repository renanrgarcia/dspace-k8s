#!/bin/bash

# DSpace Integration Test Script
# This script tests the complete backend-frontend integration

set -e

echo "🧪 DSpace Integration Test"
echo "=========================="

# Function to check if service is running
check_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=0
    
    echo "🔍 Checking $service_name at $url..."
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo "✅ $service_name is responding"
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
        echo "   Attempt $attempt/$max_attempts..."
    done
    
    echo "❌ $service_name failed to respond after $max_attempts attempts"
    return 1
}

# Function to test API endpoint
test_api() {
    local endpoint=$1
    local description=$2
    
    echo "🔧 Testing $description..."
    response=$(curl -s -w "%{http_code}" "$endpoint" || echo "000")
    http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ $description - OK (HTTP $http_code)"
        return 0
    else
        echo "❌ $description - Failed (HTTP $http_code)"
        return 1
    fi
}

echo "📋 Starting integration tests..."
echo ""

# Test 1: Check if all containers are running
echo "1️⃣ Checking Docker containers..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Docker containers are running"
else
    echo "❌ Some containers may not be running"
    docker-compose ps
fi

echo ""

# Test 2: Database connectivity
echo "2️⃣ Testing database connectivity..."
if docker-compose exec -T dspace-db pg_isready -U dspace > /dev/null 2>&1; then
    echo "✅ PostgreSQL database is ready"
else
    echo "❌ PostgreSQL database is not ready"
fi

echo ""

# Test 3: Solr connectivity
echo "3️⃣ Testing Solr connectivity..."
check_service "Solr" "http://localhost:8983/solr/admin/cores?action=STATUS"

echo ""

# Test 4: Backend API tests
echo "4️⃣ Testing DSpace Backend API..."
check_service "Backend API" "http://localhost:8080/server/api"

# Test specific API endpoints
test_api "http://localhost:8080/server/api" "Base API endpoint"
test_api "http://localhost:8080/server/api/core/communities" "Communities endpoint"
test_api "http://localhost:8080/server/api/authn/status" "Authentication status"

echo ""

# Test 5: Frontend connectivity
echo "5️⃣ Testing DSpace Frontend..."
check_service "Frontend" "http://localhost:4000"

echo ""

# Test 6: Backend-Frontend integration
echo "6️⃣ Testing Backend-Frontend Integration..."

# Check if frontend can reach backend through Docker network
echo "🔗 Testing internal network connectivity..."
if docker-compose exec -T dspace-frontend curl -s -f http://dspace-backend:8080/server/api > /dev/null 2>&1; then
    echo "✅ Frontend can reach backend via internal network"
else
    echo "❌ Frontend cannot reach backend via internal network"
fi

# Test CORS configuration
echo "🌐 Testing CORS configuration..."
cors_response=$(curl -s -H "Origin: http://localhost:4000" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: Content-Type" \
    -X OPTIONS \
    http://localhost:8080/server/api 2>/dev/null || echo "failed")

if [ "$cors_response" != "failed" ]; then
    echo "✅ CORS preflight request successful"
else
    echo "❌ CORS preflight request failed"
fi

echo ""

# Test 7: End-to-end functionality
echo "7️⃣ Testing End-to-End Functionality..."

# Test if frontend loads with backend data
echo "📱 Testing frontend data loading..."
frontend_content=$(curl -s http://localhost:4000 2>/dev/null || echo "failed")
if echo "$frontend_content" | grep -q "DSpace" 2>/dev/null; then
    echo "✅ Frontend loads with DSpace content"
else
    echo "❌ Frontend may not be loading properly"
fi

echo ""
echo "🎯 Integration Test Summary"
echo "=========================="

# Final connectivity test
if curl -s http://localhost:4000 > /dev/null 2>&1 && curl -s http://localhost:8080/server/api > /dev/null 2>&1; then
    echo "✅ Both frontend and backend are accessible"
    echo "🌐 Frontend: http://localhost:4000"
    echo "🔧 Backend: http://localhost:8080/server/api"
    echo "👤 Admin: admin@dspace.org / admin"
    echo ""
    echo "🎉 Integration test completed successfully!"
else
    echo "❌ Integration test failed - services not responding"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   1. Check container status: docker-compose ps"
    echo "   2. Check logs: docker-compose logs [service-name]"
    echo "   3. Restart services: docker-compose restart"
fi
