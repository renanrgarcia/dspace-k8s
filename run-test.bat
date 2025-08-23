@echo off
REM DSpace Integration Test - Windows Batch Script

echo 🧪 DSpace Integration Test
echo ==========================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo ✅ Docker is running

REM Start the services
echo 📦 Starting DSpace services...
echo This may take 15-20 minutes on first run...

docker-compose up -d dspace-db dspace-solr
echo ⏳ Waiting for database and Solr to initialize...
timeout /t 30 /nobreak >nul

docker-compose up -d dspace-backend
echo ⏳ Waiting for backend to build and start...
echo This can take 10-15 minutes for initial setup...

REM Wait for backend to be healthy
:wait_backend
docker-compose ps | findstr "dspace-backend" | findstr "healthy" >nul
if errorlevel 1 (
    echo Still waiting for backend...
    timeout /t 30 /nobreak >nul
    goto wait_backend
)

echo ✅ Backend is healthy

docker-compose up -d dspace-frontend
echo ⏳ Waiting for frontend to start...

REM Wait for frontend to be healthy
:wait_frontend
docker-compose ps | findstr "dspace-frontend" | findstr "healthy" >nul
if errorlevel 1 (
    echo Still waiting for frontend...
    timeout /t 15 /nobreak >nul
    goto wait_frontend
)

echo ✅ Frontend is healthy

echo.
echo 🎉 All services are running!
echo ==========================
echo 🌐 Frontend: http://localhost:4000
echo 🔧 Backend API: http://localhost:8080/server/api
echo 🔍 Solr Admin: http://localhost:8983
echo 👤 Admin: admin@dspace.org / admin
echo.

REM Test the services
echo 🧪 Testing services...

REM Test backend API
curl -s http://localhost:8080/server/api >nul 2>&1
if errorlevel 1 (
    echo ❌ Backend API not responding
) else (
    echo ✅ Backend API is responding
)

REM Test frontend
curl -s http://localhost:4000 >nul 2>&1
if errorlevel 1 (
    echo ❌ Frontend not responding
) else (
    echo ✅ Frontend is responding
)

echo.
echo 🔗 Opening DSpace in your browser...
start http://localhost:4000

echo.
echo 📋 Useful commands:
echo   View logs: docker-compose logs -f [service-name]
echo   Stop all: docker-compose down
echo   Restart: docker-compose restart [service-name]
echo   Clean reset: docker-compose down -v

pause
