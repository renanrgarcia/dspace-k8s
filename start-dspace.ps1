# DSpace 9 Docker Setup Script for Windows PowerShell
# This script sets up and starts the complete DSpace environment

Write-Host "🚀 DSpace 9 Docker Setup" -ForegroundColor Green
Write-Host "========================="

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Docker Compose is available
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose is available" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not available. Please install Docker Desktop with Compose." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created" -ForegroundColor Green
}

# Check if DSpace source exists
if (-not (Test-Path "dspace-source") -or -not (Test-Path "dspace-source\pom.xml")) {
    Write-Host "📥 DSpace source not found. Cloning DSpace 9.0..." -ForegroundColor Yellow
    git clone -b dspace-9.0 https://github.com/DSpace/DSpace.git dspace-source
    Write-Host "✅ DSpace source cloned successfully" -ForegroundColor Green
}

# Check if DSpace Angular exists
if (-not (Test-Path "dspace-angular") -or -not (Test-Path "dspace-angular\package.json")) {
    Write-Host "📥 DSpace Angular not found. Cloning DSpace Angular 9.1..." -ForegroundColor Yellow
    git clone -b dspace-9.1 https://github.com/DSpace/dspace-angular.git dspace-angular
    Write-Host "✅ DSpace Angular cloned successfully" -ForegroundColor Green
}

Write-Host "🧹 Cleaning up any existing containers..." -ForegroundColor Yellow
docker-compose down -v 2>$null

Write-Host "🏗️ Building and starting DSpace services..." -ForegroundColor Green
Write-Host "This may take 15-20 minutes on first run..." -ForegroundColor Yellow

# Start services in order
Write-Host "📦 Starting database and Solr..." -ForegroundColor Cyan
docker-compose up -d dspace-db dspace-solr

Write-Host "⏳ Waiting for database and Solr to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Start backend
Write-Host "🔧 Starting DSpace backend..." -ForegroundColor Cyan
Write-Host "This can take 10-15 minutes for initial setup..." -ForegroundColor Yellow
docker-compose up -d dspace-backend

# Wait for backend health check
Write-Host "⏳ Waiting for backend to be healthy..." -ForegroundColor Yellow
$maxAttempts = 60
$attempt = 0
do {
    Start-Sleep -Seconds 15
    $attempt++
    $status = docker-compose ps dspace-backend
    Write-Host "Attempt $attempt/$maxAttempts - Checking backend health..." -ForegroundColor Gray
    if ($status -match "healthy") {
        Write-Host "✅ Backend is healthy!" -ForegroundColor Green
        break
    }
    if ($attempt -eq $maxAttempts) {
        Write-Host "❌ Backend failed to start within 15 minutes. Check logs with: docker-compose logs dspace-backend" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} while ($true)

# Start frontend
Write-Host "🌐 Starting DSpace frontend..." -ForegroundColor Cyan
docker-compose up -d dspace-frontend

Write-Host "⏳ Waiting for frontend to be ready..." -ForegroundColor Yellow
$maxAttempts = 20
$attempt = 0
do {
    Start-Sleep -Seconds 15
    $attempt++
    $status = docker-compose ps dspace-frontend
    Write-Host "Attempt $attempt/$maxAttempts - Checking frontend health..." -ForegroundColor Gray
    if ($status -match "healthy") {
        Write-Host "✅ Frontend is healthy!" -ForegroundColor Green
        break
    }
    if ($attempt -eq $maxAttempts) {
        Write-Host "❌ Frontend failed to start within 5 minutes. Check logs with: docker-compose logs dspace-frontend" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} while ($true)

Write-Host ""
Write-Host "🎉 DSpace is now running!" -ForegroundColor Green
Write-Host "========================="
Write-Host "📱 Frontend: http://localhost:4000" -ForegroundColor Cyan
Write-Host "🔧 Backend API: http://localhost:8080/server/api" -ForegroundColor Cyan
Write-Host "🔍 Solr Admin: http://localhost:8983" -ForegroundColor Cyan
Write-Host "🗄️ Database: localhost:5432 (user: dspace, password: dspace)" -ForegroundColor Cyan
Write-Host ""
Write-Host "👤 Default Admin Account:" -ForegroundColor Yellow
Write-Host "   Email: admin@dspace.org"
Write-Host "   Password: admin"
Write-Host ""
Write-Host "📋 Useful Commands:" -ForegroundColor Yellow
Write-Host "   View logs: docker-compose logs -f [service-name]"
Write-Host "   Stop all: docker-compose down"
Write-Host "   Restart: docker-compose restart [service-name]"
Write-Host "   Clean reset: docker-compose down -v && .\start-dspace.ps1"
Write-Host ""
Write-Host "🔗 Opening DSpace frontend..." -ForegroundColor Green
Start-Process "http://localhost:4000"

Read-Host "Press Enter to continue"
