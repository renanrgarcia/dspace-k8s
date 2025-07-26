# DSpace 9 Detailed Setup Guide

This guide provides detailed instructions for setting up DSpace 9 according to the official documentation requirements.

## System Requirements

### Hardware Requirements

- **CPU**: 4+ cores recommended
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 20GB+ free space for DSpace installation
- **Network**: Internet connection for downloading dependencies

### Software Requirements

#### Required Software (Following DSpace 9.x Documentation)

- **Java**: OpenJDK 17 or Oracle JDK 17 (REQUIRED - older versions not supported)
- **Apache Maven**: 3.8.x or higher (3.9.x recommended)
- **Apache Ant**: 1.10.x or later
- **PostgreSQL**: 14.x, 15.x, 16.x, or 17.x (with pgcrypto extension)
- **Apache Solr**: 9.x series

#### Development Environment

- **Docker Desktop**: Latest version with Docker Compose
- **Windows PowerShell**: 5.1 or PowerShell Core 7.x
- **Git**: For version control

## Pre-Installation Checklist

### 1. Verify Docker Installation

```powershell
# Check Docker version
docker --version
# Should show: Docker version 20.x.x or later

# Check Docker Compose
docker-compose --version
# Should show: Docker Compose version 2.x.x or later

# Test Docker functionality
docker run hello-world
```

### 2. Check Available Ports

```powershell
# Check if required ports are available
netstat -ano | findstr ":5432"   # PostgreSQL
netstat -ano | findstr ":8080"   # DSpace Backend
netstat -ano | findstr ":8983"   # Solr
```

If any ports are in use, either:

- Stop the services using those ports
- Modify the ports in `.env` file after setup

### 3. Verify System Resources

```powershell
# Check available RAM (should be 8GB+)
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object TotalPhysicalMemory

# Check available disk space (should be 20GB+)
Get-PSDrive C | Select-Object Used,Free
```

## Installation Process

### Phase 1: Infrastructure Setup

#### 1. Clone and Configure Project

```powershell
# Navigate to your projects directory
cd C:\Users\YourUsername\Projects

# Clone the repository (if not already done)
git clone <your-repo-url> dspace-k8s
cd dspace-k8s

# Copy environment template
Copy-Item .env.example .env

# Edit .env file to customize settings
notepad .env
```

#### 2. Environment Configuration

Edit the `.env` file to customize:

```ini
# DSpace Configuration
DSPACE_VERSION=9.0
DSPACE_HOSTNAME=localhost
DSPACE_PORT=8080

# Database Configuration
POSTGRES_DB=dspace
POSTGRES_USER=dspace
POSTGRES_PASSWORD=dspace_secure_password

# Solr Configuration
SOLR_PORT=8983

# Admin Account
DSPACE_ADMIN_EMAIL=admin@your-domain.com
DSPACE_ADMIN_PASSWORD=admin_secure_password
```

### Phase 2: DSpace Installation

#### 1. Automated Setup (Recommended)

```powershell
# Run the complete setup
.\setup-dspace.ps1

# Or run step by step:
.\setup-dspace.ps1 setup
```

#### 2. Manual Setup (Advanced Users)

**Step 2.1: Start Infrastructure**

```powershell
# Start PostgreSQL and Solr
docker-compose up -d dspace-db dspace-solr

# Wait for services to be ready (about 30 seconds)
Start-Sleep -Seconds 30

# Verify PostgreSQL is running
docker exec dspace-postgres pg_isready -U dspace

# Verify Solr is running
Invoke-RestMethod "http://localhost:8983/solr/"
```

**Step 2.2: Build DSpace**

```powershell
# Run the DSpace builder
docker-compose run --rm dspace-backend-builder

# This process will:
# 1. Download DSpace 9.0 source code
# 2. Configure local.cfg for Docker environment
# 3. Build DSpace with Maven (Java 17 + Maven 3.9.9)
# 4. Install DSpace with Ant
# 5. Initialize PostgreSQL database
# 6. Create administrator account
```

**Step 2.3: Start DSpace Backend**

```powershell
# Start the DSpace backend service
docker-compose up -d dspace-backend

# Monitor the startup process
docker-compose logs -f dspace-backend
```

### Phase 3: Verification and Testing

#### 1. Service Health Checks

```powershell
# Check all services are running
docker-compose ps

# Test REST API
Invoke-RestMethod "http://localhost:8080/server/api"

# Test OAI-PMH
Invoke-RestMethod "http://localhost:8080/server/oai/request?verb=Identify"

# Test Solr
Invoke-RestMethod "http://localhost:8983/solr/"
```

#### 2. Database Verification

```powershell
# Connect to PostgreSQL and check tables
docker exec -it dspace-postgres psql -U dspace -d dspace -c "\dt"

# Check DSpace schema version
docker exec -it dspace-postgres psql -U dspace -d dspace -c "SELECT * FROM schema_version ORDER BY installed_rank DESC LIMIT 5;"
```

#### 3. Administrator Account Verification

```powershell
# Check if admin account was created
docker exec -it dspace-postgres psql -U dspace -d dspace -c "SELECT email, firstname, lastname FROM eperson WHERE email='admin@dspace.org';"
```

## Configuration Details

### Java Environment

The setup uses **Eclipse Temurin OpenJDK 17**, which is:

- Fully compatible with DSpace 9 requirements
- Long-term support (LTS) version
- Optimized for production use
- Includes all necessary JVM optimizations

### Maven Configuration

- **Version**: 3.9.9 (latest stable)
- **Memory Settings**: `-Xmx2g -Xms1g`
- **Repository**: Uses local Maven repository for faster builds
- **Profiles**: Configured for DSpace-specific plugins

### Database Configuration

- **PostgreSQL**: Version 17.x (latest supported)
- **Extensions**: pgcrypto (required for DSpace)
- **Character Set**: UTF-8
- **Connections**: Max 30 connections for production
- **Memory**: Optimized for 8GB+ systems

### Solr Configuration

- **Version**: 9.8.x (latest 9.x series)
- **Cores**: Pre-configured for DSpace collections
- **Memory**: 2GB heap for optimal performance
- **Configuration**: DSpace-optimized solrconfig.xml

## Advanced Configuration

### Custom DSpace Configuration

To modify DSpace settings:

1. **Edit local.cfg template** in the `Dockerfile` (automatically generated during build)
2. **Rebuild DSpace**:
   ```powershell
   .\setup-dspace.ps1 clean
   .\setup-dspace.ps1 setup
   ```

### Production Settings

For production deployment:

```powershell
# Use production Docker Compose override
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

This includes:

- Resource limits and reservations
- Restart policies
- Logging configuration
- Security enhancements
- Performance optimizations

### Performance Tuning

#### Memory Allocation

- **DSpace Backend**: 4GB max, 2GB reserved
- **PostgreSQL**: 2GB max, 512MB reserved
- **Solr**: 3GB max, 1GB reserved

#### Database Tuning

```sql
-- PostgreSQL optimization (applied automatically)
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
max_connections = 100
```

#### JVM Tuning

```bash
# Applied automatically in production mode
-Xms2g -Xmx4g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+HeapDumpOnOutOfMemoryError
```

## Troubleshooting

### Common Build Issues

#### Maven Build Failures

```powershell
# Clear Maven cache and retry
docker-compose run --rm dspace-backend-builder mvn clean -f /dspace-source

# Check Maven version
docker-compose run --rm dspace-backend-builder mvn --version
```

#### Database Connection Issues

```powershell
# Check PostgreSQL logs
docker-compose logs dspace-db

# Reset database
docker-compose down -v
docker-compose up -d dspace-db
```

#### Solr Connection Issues

```powershell
# Check Solr logs
docker-compose logs dspace-solr

# Restart Solr
docker-compose restart dspace-solr
```

### Performance Issues

#### Slow Build Times

- Increase Docker Desktop memory allocation to 8GB+
- Use SSD storage for Docker volumes
- Close unnecessary applications during build

#### High Memory Usage

- Reduce Java heap sizes in docker-compose.yml
- Limit number of concurrent Maven threads
- Monitor with `docker stats`

### Network Issues

#### Port Conflicts

```powershell
# Find process using port
netstat -ano | findstr ":8080"

# Kill process (replace PID)
taskkill /PID <process_id> /F
```

#### DNS Resolution

```powershell
# Test container networking
docker exec dspace-backend ping dspace-postgres
docker exec dspace-backend ping dspace-solr
```

## Maintenance

### Regular Tasks

#### Backup Database

```powershell
# Create database backup
docker exec dspace-postgres pg_dump -U dspace dspace > dspace_backup_$(Get-Date -Format "yyyyMMdd").sql
```

#### Update DSpace

1. Check for new DSpace releases
2. Update DSPACE_VERSION in .env
3. Rebuild: `.\setup-dspace.ps1 clean && .\setup-dspace.ps1`

#### Log Management

```powershell
# View log sizes
docker system df

# Clean old logs
docker system prune -f
```

### Monitoring

#### Service Health

```powershell
# Check service status
.\setup-dspace.ps1 status

# Monitor resource usage
docker stats
```

#### Log Analysis

```powershell
# Follow all logs
docker-compose logs -f

# Filter specific service
docker-compose logs -f dspace-backend | findstr "ERROR"
```

## Next Steps

### Frontend Setup

After the backend is working:

1. Set up DSpace Angular frontend
2. Configure frontend-backend communication
3. Test complete workflow

### Kubernetes Migration

Prepare for production deployment:

1. Convert Docker Compose to Kubernetes manifests
2. Set up persistent volumes
3. Configure ingress controllers
4. Implement monitoring and logging

## Support Resources

- **DSpace 9 Documentation**: https://wiki.lyrasis.org/display/DSDOC9x/
- **DSpace Community**: https://groups.google.com/g/dspace-community
- **Technical Support**: https://github.com/DSpace/DSpace/issues
- **Docker Documentation**: https://docs.docker.com/
