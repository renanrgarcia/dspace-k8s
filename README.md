# DSpace 9 Docker Backend

A containerized DSpace 9 backend environment using Docker and Docker Compose, designed for easy setup and frontend integration.

## Prerequisites

- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Git**: For cloning DSpace source code
- **System Requirements**:
  - 8GB+ RAM (DSpace is memory-intensive)
  - 20GB+ free disk space

## Quick Start

### 1. Clone DSpace Source Code

The DSpace source code needs to be placed in the `dspace-source` directory:

```bash
# Clone DSpace 9.0 source
git clone -b dspace-9.0 https://github.com/DSpace/DSpace.git dspace-source
```

### 2. Environment Configuration

Copy the example environment file and customize if needed:

```bash
cp .env.example .env
```

Default configuration should work for local development. Key variables:

- `DSPACE_PORT=8080` - Backend API port
- `POSTGRES_PORT=5432` - Database port
- `SOLR_PORT=8983` - Search engine port
- `ADMIN_EMAIL=admin@dspace.org` - Default admin email
- `ADMIN_PASSWORD=admin` - Default admin password

### 3. Start the Backend

Build and start all services:

```bash
# Start all services (database, solr, dspace backend)
docker-compose up -d

# View logs
docker-compose logs -f dspace-backend
```

First startup will take 10-15 minutes as it:

- Downloads dependencies
- Builds DSpace from source
- Initializes the database
- Configures Solr cores

### 4. Verify Installation

Check that all services are running:

```bash
# Check service status
docker-compose ps

# Test REST API
curl http://localhost:8080/server/api

# Access Solr admin (optional)
# Open http://localhost:8983 in browser
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

- **dspace-db** (PostgreSQL 17): Main database
- **dspace-solr** (Solr 9.8): Search and discovery engine
- **dspace-backend-builder**: Builds DSpace from source (runs once)
- **dspace-backend**: Runs the DSpace REST API server

### Ports

- `8080`: DSpace REST API
- `5432`: PostgreSQL database
- `8983`: Solr admin interface

### Volumes

- `postgres_data`: Database persistence
- `solr_data`: Search index persistence
- `maven_cache`: Maven dependencies cache
- `./dspace-install`: DSpace installation directory
- `./dspace-source`: DSpace source code

## Frontend Integration

### CORS Configuration

The backend is configured to allow CORS requests from frontend applications. Default allowed origins include:

- `http://localhost:4200` (Angular dev server)
- `http://localhost:3000` (React/Next.js dev server)

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
