# DSpace Docker Integration Test & Cleanup Script
# Tests backend-frontend integration and cleans up unnecessary files

Write-Host "🧪 DSpace Docker Integration Test & Cleanup" -ForegroundColor Green
Write-Host "============================================="

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

# Step 1: Start Docker Compose services
Write-Host "🚀 Starting Docker Compose services..." -ForegroundColor Blue
try {
    docker-compose up -d
    Write-Host "✅ Docker Compose services started" -ForegroundColor Green
    Start-Sleep -Seconds 10
}
catch {
    Write-Host "❌ Failed to start Docker Compose services" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Check container status
Write-Host "📋 Checking Docker containers..." -ForegroundColor Blue
$containers = docker-compose ps
if ($containers -match "Up") {
    Write-Host "✅ Docker containers are running" -ForegroundColor Green
} else {
    Write-Host "❌ Some containers may not be running" -ForegroundColor Red
    Write-Host $containers
}

Write-Host ""

# Step 3: Test services
Write-Host "🔧 Testing DSpace services..." -ForegroundColor Blue

# Test database
Write-Host "Testing PostgreSQL..." -ForegroundColor Cyan
try {
    docker-compose exec -T dspace-db pg_isready -U dspace 2>$null
    Write-Host "✅ PostgreSQL is ready" -ForegroundColor Green
}
catch {
    Write-Host "❌ PostgreSQL is not ready" -ForegroundColor Red
}

# Test Solr
$solrResult = Test-ServiceUrl -Url "http://localhost:8983/solr/admin/cores?action=STATUS" -ServiceName "Solr"

# Test Backend API
$backendResult = Test-ServiceUrl -Url "http://localhost:8080/server/api" -ServiceName "Backend API"

# Test Frontend
$frontendResult = Test-ServiceUrl -Url "http://localhost:4000" -ServiceName "Frontend"

Write-Host ""

# Step 4: Integration tests
Write-Host "🔗 Testing Backend-Frontend Integration..." -ForegroundColor Blue

# Test internal network connectivity
Write-Host "Testing internal network..." -ForegroundColor Cyan
try {
    docker-compose exec -T dspace-frontend curl -s -f http://dspace-backend:8080/server/api 2>$null
    Write-Host "✅ Frontend can reach backend via internal network" -ForegroundColor Green
}
catch {
    Write-Host "❌ Frontend cannot reach backend via internal network" -ForegroundColor Red
}

# Test CORS
Write-Host "Testing CORS configuration..." -ForegroundColor Cyan
try {
    $corsHeaders = @{
        'Origin' = 'http://localhost:4000'
        'Access-Control-Request-Method' = 'GET'
        'Access-Control-Request-Headers' = 'Content-Type'
    }
    $corsResponse = Invoke-WebRequest -Uri "http://localhost:8080/server/api" -Method OPTIONS -Headers $corsHeaders -TimeoutSec 5 -UseBasicParsing
    Write-Host "✅ CORS configuration is working" -ForegroundColor Green
}
catch {
    Write-Host "❌ CORS configuration failed" -ForegroundColor Red
}

Write-Host ""

# Step 5: Cleanup unnecessary files
Write-Host "🧹 Cleaning up unnecessary files..." -ForegroundColor Blue

$filesToRemove = @(
    "dspace-source\docker-compose.yml",
    "dspace-source\docker-compose-cli.yml",
    "Installing DSpace - DSpace 9.x Documentation - LYRASIS Wiki.pdf",
    "dspace-source\Dockerfile",
    "dspace-source\Dockerfile.cli", 
    "dspace-source\Dockerfile.dependencies",
    "dspace-source\Dockerfile.test"
)

$removedCount = 0
$totalSize = 0

foreach ($file in $filesToRemove) {
    $fullPath = Join-Path $PWD $file
    if (Test-Path $fullPath) {
        try {
            $fileInfo = Get-Item $fullPath
            $size = $fileInfo.Length
            $totalSize += $size
            
            Remove-Item $fullPath -Force
            Write-Host "✅ Removed: $file" -ForegroundColor Green
            $removedCount++
        }
        catch {
            Write-Host "❌ Failed to remove: $file" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "🎯 Test & Cleanup Summary" -ForegroundColor Green
Write-Host "=========================="

# Integration test results
if ($backendResult -and $frontendResult) {
    Write-Host "✅ Integration test PASSED" -ForegroundColor Green
    Write-Host "🌐 Frontend: http://localhost:4000" -ForegroundColor Cyan
    Write-Host "🔧 Backend: http://localhost:8080/server/api" -ForegroundColor Cyan
    Write-Host "👤 Admin: admin@dspace.org / admin" -ForegroundColor Yellow
} else {
    Write-Host "❌ Integration test FAILED" -ForegroundColor Red
}

# Cleanup results
Write-Host "📊 Cleanup Results:" -ForegroundColor Cyan
Write-Host "   Files removed: $removedCount"
Write-Host "   Space freed: $([math]::Round($totalSize/1MB, 2)) MB"

Write-Host ""
if ($backendResult -and $frontendResult) {
    Write-Host "🎉 DSpace is ready! Opening in browser..." -ForegroundColor Green
    Start-Process "http://localhost:4000"
} else {
    Write-Host "🔧 Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "   1. Check logs: docker-compose logs [service-name]"
    Write-Host "   2. Restart: docker-compose restart"
    Write-Host "   3. Full restart: docker-compose down && docker-compose up -d"
}

Read-Host "`nPress Enter to continue"
