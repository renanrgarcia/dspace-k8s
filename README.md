# DSpace 9 Complete Docker Setup

A fully containerized DSpace 9 environment with both backend and frontend using Docker and Docker Compose, following DSpace 9.x documentation requirements.

## Prerequisites

- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Git**: For cloning DSpace source code
- **System Requirements**:
  - 8GB+ RAM (DSpace is memory-intensive)
  - 20GB+ free disk space
  - Ports 4000, 8080, 5432, 8983 available

## Quick Start

### Option 1: Automated Setup (Recommended)

Use the provided startup script for a complete automated setup:

```bash
# Make the script executable (Linux/Mac)
chmod +x start-dspace.sh

# Run the automated setup
./start-dspace.sh
```

### Option 2: Manual Setup

#### 1. Clone Required Repositories

```bash
# Clone DSpace 9.0 backend source
git clone -b dspace-9.0 https://github.com/DSpace/DSpace.git dspace-source

# Clone DSpace Angular 9.1 frontend
git clone -b dspace-9.1 https://github.com/DSpace/dspace-angular.git dspace-angular
```

#### 2. Environment Configuration

```bash
# Copy and customize environment variables
cp .env.example .env
```

#### 3. Start All Services

```bash
# Start database and Solr first
docker-compose up -d dspace-db dspace-solr

# Wait 30 seconds, then start backend
docker-compose up -d dspace-backend

# Wait for backend to be healthy, then start frontend
docker-compose up -d dspace-frontend
```

First startup will take 15-20 minutes as it:

- Downloads and builds DSpace from source
- Builds Angular frontend
- Initializes the database
- Configures Solr cores
- Creates admin user

## Access Points

Once all services are running:

- **🌐 DSpace Frontend**: http://localhost:4000
- **🔧 Backend REST API**: http://localhost:8080/server/api
- **🔍 Solr Admin**: http://localhost:8983
- **🗄️ PostgreSQL**: localhost:5432 (user: dspace, password: dspace)

### Default Admin Account

- **Email**: admin@dspace.org
- **Password**: admin

## Verification

Check that all services are running:

```bash
# Check service status
docker-compose ps

# Test backend API
curl http://localhost:8080/server/api

# Test frontend (should return HTML)
curl http://localhost:4000
```

Expected API response:
```json
{
  "dspaceApi": {
    "version": "9.0"
  }
}
```

## Architecture

### Services

- **dspace-db** (PostgreSQL 17): Main database with pgcrypto extension
- **dspace-solr** (Solr 9.8): Search and discovery engine with custom cores
- **dspace-backend**: DSpace REST API server (Spring Boot)
- **dspace-frontend**: Angular frontend application with SSR

### Ports

- `4000`: DSpace Angular Frontend
- `8080`: DSpace REST API
- `5432`: PostgreSQL database
- `8983`: Solr admin interface

### Volumes

- `postgres_data`: Database persistence
- `solr_data`: Search index persistence
- `dspace_install`: DSpace installation directory
- `dspace_logs`: DSpace application logs
- `./dspace-source`: DSpace backend source code (mounted for development)
- `./dspace-angular`: Angular frontend source code (mounted for development)

## Frontend Integration

### Backend-Frontend Communication

The setup ensures proper communication between backend and frontend:

- **CORS**: Backend configured to allow requests from `http://localhost:4000`
- **Service Discovery**: Frontend connects to backend via Docker network (`dspace-backend:8080`)
- **Health Checks**: Services wait for dependencies to be healthy before starting

### API Endpoints

Key REST API endpoints for frontend integration:

- **Base API**: `http://localhost:8080/server/api`
- **Communities**: `GET /api/core/communities`
- **Collections**: `GET /api/core/collections`
- **Items**: `GET /api/core/items`
- **Search**: `GET /api/discover/search/objects`
- **Authentication**: `POST /api/authn/login`

### Authentication

For frontend authentication:

1. **Login**: `POST /api/authn/login`
2. **Logout**: `POST /api/authn/logout`
3. **Status**: `GET /api/authn/status`

Admin credentials (from `.env`):

- Email: `admin@dspace.org`
- Password: `admin`

## Development Workflow

### Making Changes

1. **Source Code Changes**: Edit files in `./dspace-source`
2. **Rebuild**: `docker-compose down && docker-compose up --build`
3. **Config Changes**: Edit `./dspace-source/dspace/config/local.cfg`

### Useful Commands

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (fresh start)
docker-compose down -v

# View logs for a specific service
docker-compose logs -f dspace-backend

# Execute commands in containers
docker-compose exec dspace-backend bash
docker-compose exec dspace-db psql -U dspace -d dspace

# Rebuild specific service
docker-compose up --build dspace-backend
```

### Database Access

```bash
# Connect to PostgreSQL
docker-compose exec dspace-db psql -U dspace -d dspace

# Common SQL queries
SELECT * FROM metadataschemaregistry;
SELECT * FROM eperson;
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 8080, 5432, 8983 are not in use
2. **Memory issues**: Increase Docker memory allocation to 8GB+
3. **Build failures**: Check Maven cache: `docker-compose down -v`

### Logs

Check logs for debugging:

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs dspace-backend
docker-compose logs dspace-db
docker-compose logs dspace-solr
```

### Reset Environment

Complete reset (removes all data):

```bash
docker-compose down -v
docker system prune -f
docker-compose up --build
```

## Production Considerations

For production deployment:

1. **Use production compose file**: `docker-compose -f docker-compose.prod.yml up`
2. **Configure external database**: Set proper PostgreSQL credentials
3. **Enable HTTPS**: Use reverse proxy (nginx/traefik)
4. **Set proper CORS origins**: Update allowed origins for your domain
5. **Resource limits**: Set memory/CPU limits in compose file

## Next Steps

1. **Frontend Integration**: Connect your Angular/React frontend to `http://localhost:8080/server/api`
2. **Content Loading**: Use DSpace admin interface or REST API to add communities/collections
3. **Customization**: Modify themes, metadata schemas, and workflows as needed

## Support

- **DSpace Documentation**: https://wiki.lyrasis.org/display/DSDOC9x
- **REST API Documentation**: https://wiki.lyrasis.org/display/DSDOC9x/REST+API
- **Docker Issues**: Check `docker-compose logs` for debugging
