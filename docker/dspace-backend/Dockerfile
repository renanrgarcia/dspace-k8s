FROM eclipse-temurin:17-jdk-jammy

# Install required packages
RUN apt-get update && apt-get install -y \
    maven \
    ant \
    postgresql-client \
    curl \
    netcat-openbsd \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /dspace-source

# Copy DSpace source code
COPY ./dspace-source .

# Set environment variables
ENV DSPACE_INSTALL=/dspace
ENV MAVEN_OPTS="-Xmx2g -Xms1g"

# Build DSpace with proper Maven configuration and install
RUN echo "Building DSpace with Maven..." && \
    mvn clean install -DskipTests -Dcheckstyle.skip=true -Denforcer.skip=true -Dmaven.javadoc.skip=true && \
    echo "Maven build completed. Installing DSpace..." && \
    cd dspace/target/dspace-installer && \
    ant fresh_install && \
    echo "DSpace installation completed. Listing installed files:" && \
    ls -la /dspace/bin/ && \
    echo "Listing jar files:" && \
    find /dspace -name "*.jar" | head -10

# Find and copy Spring Boot server jar
RUN echo "Finding Spring Boot server jar..." && \
    find /dspace-source -name "*.jar" | grep -E "(server|boot)" && \
    echo "Contents of dspace/target:" && \
    ls -la dspace/target/ && \
    echo "Contents of dspace-server/target:" && \
    ls -la dspace-server/target/ || echo "No dspace-server directory" && \
    echo "Looking for main classes..." && \
    find /dspace-source -name "*.class" | grep -i "application\|main" | head -10 && \
    mkdir -p /app && \
    find /dspace-source -name "dspace-server-*.jar" -exec cp {} /app/server.jar \; || \
    find /dspace-source -name "*server*.jar" -exec cp {} /app/server.jar \; || \
    echo "No server jar found"

# Create config directory and local.cfg for database configuration
RUN mkdir -p /dspace/config && \
    echo "# Database Configuration\n\
db.url = jdbc:postgresql://dspace-db:5432/dspace\n\
db.username = dspace\n\
db.password = dspace\n\
db.driver = org.postgresql.Driver\n\
db.dialect = org.hibernate.dialect.PostgreSQL94Dialect\n\
\n\
# Solr Configuration\n\
solr.server = http://dspace-solr:8983/solr\n\
\n\
# Basic Configuration\n\
dspace.hostname = localhost\n\
dspace.baseUrl = http://localhost:8080\n\
dspace.ui.url = http://localhost:4000\n\
dspace.name = DSpace Repository\n\
" > /dspace/config/local.cfg

# Create startup script with improved error handling and Spring Boot detection
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting DSpace Backend Container..."\n\
echo "Waiting for PostgreSQL..."\n\
timeout=60\n\
while ! nc -z dspace-db 5432 && [ $timeout -gt 0 ]; do\n\
  echo "PostgreSQL not ready, waiting... ($timeout seconds left)"\n\
  sleep 2\n\
  timeout=$((timeout-2))\n\
done\n\
if [ $timeout -le 0 ]; then\n\
  echo "ERROR: PostgreSQL connection timeout"\n\
  exit 1\n\
fi\n\
echo "PostgreSQL is ready!"\n\
\n\
echo "Waiting for Solr..."\n\
timeout=60\n\
while ! nc -z dspace-solr 8983 && [ $timeout -gt 0 ]; do\n\
  echo "Solr not ready, waiting... ($timeout seconds left)"\n\
  sleep 2\n\
  timeout=$((timeout-2))\n\
done\n\
if [ $timeout -le 0 ]; then\n\
  echo "WARNING: Solr connection timeout, continuing anyway"\n\
fi\n\
\n\
cd /dspace-source\n\
echo "Current directory: $(pwd)"\n\
\n\
# Look for Spring Boot executable jar\n\
echo "Looking for Spring Boot executable jar..."\n\
SPRING_BOOT_JAR=$(find . -name "*server*.jar" -path "*/target/*" -executable 2>/dev/null | head -1)\n\
if [ -z "$SPRING_BOOT_JAR" ]; then\n\
  SPRING_BOOT_JAR=$(find . -name "*boot*.jar" -path "*/target/*" 2>/dev/null | head -1)\n\
fi\n\
if [ -z "$SPRING_BOOT_JAR" ]; then\n\
  SPRING_BOOT_JAR=$(find . -name "*.jar" -path "*/target/*" | grep -E "(server|boot|spring)" | head -1)\n\
fi\n\
\n\
if [ -n "$SPRING_BOOT_JAR" ] && [ -f "$SPRING_BOOT_JAR" ]; then\n\
  echo "Found Spring Boot jar: $SPRING_BOOT_JAR"\n\
  echo "Starting DSpace with Spring Boot jar..."\n\
  exec java -Xmx2g -Xms1g \\\n\
    -Ddspace.dir=/dspace \\\n\
    -Ddspace.configuration=/dspace/config/local.cfg \\\n\
    -Dspring.profiles.active=docker \\\n\
    -jar "$SPRING_BOOT_JAR"\n\
else\n\
  echo "No Spring Boot jar found, using installed DSpace..."\n\
  if [ -f "/dspace/bin/dspace" ]; then\n\
    echo "Using installed DSpace binary"\n\
    exec /dspace/bin/dspace server\n\
  else\n\
    echo "Creating DSpace command script with proper classpath..."\n\
    mkdir -p /dspace/bin\n\
    cat > /dspace/bin/dspace << "EOF"\n\
#!/bin/bash\n\
JAVA_OPTS="-Xmx2g -Xms1g -Ddspace.dir=/dspace"\n\
CLASSPATH=""\n\
# Add DSpace lib jars\n\
for jar in /dspace/lib/*.jar; do\n\
  [ -f "$jar" ] && CLASSPATH="$CLASSPATH:$jar"\n\
done\n\
# Add source jars as fallback\n\
for jar in $(find /dspace-source -name "*.jar" -path "*/target/*" | grep -v test); do\n\
  CLASSPATH="$CLASSPATH:$jar"\n\
done\n\
# Add classes directories\n\
for classes in $(find /dspace-source -name "classes" -path "*/target/*" -type d); do\n\
  CLASSPATH="$CLASSPATH:$classes"\n\
done\n\
CLASSPATH="${CLASSPATH#:}"\n\
echo "Using classpath: $CLASSPATH"\n\
exec java $JAVA_OPTS -cp "$CLASSPATH" org.dspace.app.launcher.ScriptLauncher "$@"\n\
EOF\n\
    chmod +x /dspace/bin/dspace\n\
    echo "Starting DSpace server..."\n\
    exec /dspace/bin/dspace server\n\
  fi\n\
fi\n\
' > /startup.sh && chmod +x /startup.sh

# Set working directory
WORKDIR /dspace

# Expose port
EXPOSE 8080

# Start DSpace
CMD ["/startup.sh"]
