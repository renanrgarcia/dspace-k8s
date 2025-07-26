# DSpace Frontend Installation Instructions

## Prerequisites

Before installing the DSpace frontend, ensure you have:

1. **DSpace Backend Running**: The backend must be accessible at `dspace-backend:8080`
2. **DSpace Frontend Source**: Download from the official DSpace repository
3. **Docker and Docker Compose**: Latest versions installed

## Step 1: Download DSpace Frontend Source

```bash
# Navigate to project root
cd /path/to/dspace-k8s

# Download DSpace frontend source (replace with your preferred method)
git clone https://github.com/DSpace/dspace-angular.git dspace-frontend
cd dspace-frontend
git checkout dspace-9.0  # Use the appropriate version tag

# Or download and extract from releases
wget https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-9.0.tar.gz
tar -xzf dspace-9.0.tar.gz
mv dspace-angular-dspace-9.0 dspace-frontend
```

## Step 2: Configure Environment

The environment configuration files are already prepared in `docker/dspace-frontend/config/`:

- `environment.ts` - Development configuration
- `environment.prod.ts` - Production configuration

These will be automatically copied to the correct location during the Docker build.

## Step 3: Build and Run

```bash
# From the project root directory
docker-compose up -d --build

# Or build only the frontend
docker-compose build dspace-frontend
docker-compose up -d dspace-frontend
```

## Step 4: Verify Installation

1. **Check Container Status**:

   ```bash
   docker-compose ps
   ```

2. **View Logs**:

   ```bash
   docker-compose logs -f dspace-frontend
   ```

3. **Test Frontend**:

   - Open browser to http://localhost:4000
   - Verify the DSpace homepage loads
   - Check that API calls work (browse collections, etc.)

4. **Test API Proxy**:
   - http://localhost:4000/server/api should return backend API responses

## Configuration Details

### Backend Integration

The frontend is configured to connect to the backend via:

- **REST API**: `http://dspace-backend:8080/server`
- **Proxy**: All `/server/*` requests are proxied to the backend
- **CORS**: Backend allows requests from `http://localhost:4000`

### Environment Variables

Key environment variables that can be customized in `docker-compose.yml`:

```yaml
environment:
  DSPACE_UI_HOST: "localhost"
  DSPACE_UI_PORT: "4000"
  DSPACE_REST_HOST: "dspace-backend"
  DSPACE_REST_PORT: "8080"
  DSPACE_REST_NAMESPACE: "/server"
  DSPACE_REST_SSL: "false"
```

## Troubleshooting

### Common Issues

1. **Frontend Won't Start**:

   ```bash
   # Check if backend is running
   docker-compose ps

   # Check frontend logs
   docker-compose logs dspace-frontend
   ```

2. **API Calls Failing**:

   ```bash
   # Verify backend is accessible
   curl http://localhost:8080/server/api

   # Check proxy configuration in nginx.conf
   ```

3. **Build Failures**:
   ```bash
   # Clear Docker cache and rebuild
   docker-compose down
   docker system prune -f
   docker-compose up -d --build --no-cache
   ```

### Port Conflicts

If port 4000 is already in use:

```yaml
# In docker-compose.yml, change:
ports:
  - "4001:4000" # Use port 4001 instead
```

### Performance Issues

1. **Increase Build Resources**:

   ```bash
   # Increase Docker memory limit to 4GB or more
   ```

2. **Check System Resources**:
   ```bash
   docker stats
   ```

## Development Mode

For development with hot reloading:

```bash
# Navigate to dspace-frontend source
cd dspace-frontend

# Install dependencies
npm install

# Start development server
npm run start:dev

# Frontend will be available at http://localhost:4000
# Changes will auto-reload
```

## Production Considerations

For production deployment:

1. **Use HTTPS**: Configure SSL certificates
2. **Domain Names**: Update hostnames in environment files
3. **Security**: Review and enhance security headers
4. **Monitoring**: Set up application monitoring
5. **Backup**: Implement backup strategies for user data

## Next Steps

After successful installation:

1. **Test All Features**: Browse, search, submit items
2. **Configure Themes**: Customize appearance if needed
3. **Set Up Authentication**: Configure user authentication
4. **Performance Tuning**: Optimize for your expected load
5. **Backup Strategy**: Plan for data backup and recovery

The frontend should now be fully integrated with your DSpace backend and ready for use!
