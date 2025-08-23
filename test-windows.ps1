# DSpace Integration Test Script for Windows PowerShell
# This script tests the complete backend-frontend integration

Write-Host "🧪 DSpace Integration Test" -ForegroundColor Green
Write-Host "=========================="

# Function to test URL
function Test-ServiceUrl {
    param(
        [string]$Url,
        [string]$ServiceName,
        [int]$MaxAttempts = 10
    )
    
    Write-Host "🔍 Testing $ServiceName at $Url..." -ForegroundColor Cyan
    
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $ServiceName is responding (HTTP $($response.StatusCode))" -ForegroundColor Green
                return $true
            }
        }
        catch {
            Write-Host "   Attempt $i/$MaxAttempts failed..." -ForegroundColor Gray
            Start-Sleep -Seconds 3
        }
    }
    
    Write-Host "❌ $ServiceName failed to respond after $MaxAttempts attempts" -ForegroundColor Red
    return $false
}

Write-Host "📋 Starting integration tests..." -ForegroundColor Yellow
Write-Host ""

# Test 1: Check Docker containers
Write-Host "1️⃣ Checking Docker containers..." -ForegroundColor Blue
$containers = docker-compose ps
if ($containers -match "Up") {
    Write-Host "✅ Docker containers are running" -ForegroundColor Green
    Write-Host $containers
} else {
    Write-Host "❌ Some containers may not be running" -ForegroundColor Red
    Write-Host $containers
}

Write-Host ""

# Test 2: Database connectivity
Write-Host "2️⃣ Testing database connectivity..." -ForegroundColor Blue
try {
    $dbTest = docker-compose exec -T dspace-db pg_isready -U dspace 2>$null
    Write-Host "✅ PostgreSQL database is ready" -ForegroundColor Green
}
catch {
    Write-Host "❌ PostgreSQL database is not ready" -ForegroundColor Red
}

Write-Host ""

# Test 3: Solr connectivity
Write-Host "3️⃣ Testing Solr connectivity..." -ForegroundColor Blue
$solrResult = Test-ServiceUrl -Url "http://localhost:8983/solr/admin/cores?action=STATUS" -ServiceName "Solr Admin"

Write-Host ""

# Test 4: Backend API tests
Write-Host "4️⃣ Testing DSpace Backend API..." -ForegroundColor Blue
$backendResult = Test-ServiceUrl -Url "http://localhost:8080/server/api" -ServiceName "Backend API"

if ($backendResult) {
    # Test specific endpoints
    Write-Host "🔧 Testing specific API endpoints..." -ForegroundColor Cyan
    
    $endpoints = @(
        @{Url="http://localhost:8080/server/api"; Name="Base API"},
        @{Url="http://localhost:8080/server/api/core/communities"; Name="Communities"},
        @{Url="http://localhost:8080/server/api/authn/status"; Name="Auth Status"}
    )
    
    foreach ($endpoint in $endpoints) {
        try {
            $response = Invoke-WebRequest -Uri $endpoint.Url -TimeoutSec 5 -UseBasicParsing
            Write-Host "✅ $($endpoint.Name) - OK (HTTP $($response.StatusCode))" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ $($endpoint.Name) - Failed" -ForegroundColor Red
        }
    }
}

Write-Host ""

# Test 5: Frontend connectivity
Write-Host "5️⃣ Testing DSpace Frontend..." -ForegroundColor Blue
$frontendResult = Test-ServiceUrl -Url "http://localhost:4000" -ServiceName "Frontend"

Write-Host ""

# Test 6: Integration test
Write-Host "6️⃣ Testing Backend-Frontend Integration..." -ForegroundColor Blue

# Test internal network connectivity
Write-Host "🔗 Testing internal network connectivity..." -ForegroundColor Cyan
try {
    $networkTest = docker-compose exec -T dspace-frontend curl -s -f http://dspace-backend:8080/server/api 2>$null
    Write-Host "✅ Frontend can reach backend via internal network" -ForegroundColor Green
}
catch {
    Write-Host "❌ Frontend cannot reach backend via internal network" -ForegroundColor Red
}

# Test CORS
Write-Host "🌐 Testing CORS configuration..." -ForegroundColor Cyan
try {
    $corsHeaders = @{
        'Origin' = 'http://localhost:4000'
        'Access-Control-Request-Method' = 'GET'
        'Access-Control-Request-Headers' = 'Content-Type'
    }
    $corsResponse = Invoke-WebRequest -Uri "http://localhost:8080/server/api" -Method OPTIONS -Headers $corsHeaders -TimeoutSec 5 -UseBasicParsing
    Write-Host "✅ CORS preflight request successful" -ForegroundColor Green
}
catch {
    Write-Host "❌ CORS preflight request failed" -ForegroundColor Red
}

Write-Host ""

# Test 7: End-to-end functionality
Write-Host "7️⃣ Testing End-to-End Functionality..." -ForegroundColor Blue

Write-Host "📱 Testing frontend content loading..." -ForegroundColor Cyan
try {
    $frontendContent = Invoke-WebRequest -Uri "http://localhost:4000" -TimeoutSec 10 -UseBasicParsing
    if ($frontendContent.Content -match "DSpace") {
        Write-Host "✅ Frontend loads with DSpace content" -ForegroundColor Green
    } else {
        Write-Host "❌ Frontend may not be loading DSpace content properly" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Frontend content test failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Integration Test Summary" -ForegroundColor Green
Write-Host "=========================="

# Final summary
if ($backendResult -and $frontendResult) {
    Write-Host "✅ Both frontend and backend are accessible" -ForegroundColor Green
    Write-Host "🌐 Frontend: http://localhost:4000" -ForegroundColor Cyan
    Write-Host "🔧 Backend: http://localhost:8080/server/api" -ForegroundColor Cyan
    Write-Host "👤 Admin: admin@dspace.org / admin" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🎉 Integration test completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔗 Opening DSpace in browser..." -ForegroundColor Cyan
    Start-Process "http://localhost:4000"
} else {
    Write-Host "❌ Integration test failed - some services not responding" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Check container status: docker-compose ps"
    Write-Host "   2. Check logs: docker-compose logs [service-name]"
    Write-Host "   3. Restart services: docker-compose restart"
    Write-Host "   4. Full restart: docker-compose down && .\start-dspace.ps1"
}

Read-Host "`nPress Enter to continue"
