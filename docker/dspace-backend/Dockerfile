FROM eclipse-temurin:17-jdk-jammy

# Install required packages
RUN apt-get update && apt-get install -y \
    maven \
    ant \
    postgresql-client \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install Tomcat 10
RUN apt-get update && apt-get install -y \
    tomcat10 \
    && rm -rf /var/lib/apt/lists/* || \
    (apt-get update && apt-get install -y \
    tomcat9 \
    && rm -rf /var/lib/apt/lists/*)

# Ensure Tomcat configuration is properly set up
RUN if [ -d "/usr/share/tomcat10" ]; then \
        ln -sf /var/lib/tomcat10/conf /usr/share/tomcat10/conf; \
        ln -sf /var/lib/tomcat10/logs /usr/share/tomcat10/logs; \
        ln -sf /var/lib/tomcat10/work /usr/share/tomcat10/work; \
        ln -sf /var/lib/tomcat10/temp /usr/share/tomcat10/temp; \
    elif [ -d "/usr/share/tomcat9" ]; then \
        ln -sf /var/lib/tomcat9/conf /usr/share/tomcat9/conf; \
        ln -sf /var/lib/tomcat9/logs /usr/share/tomcat9/logs; \
        ln -sf /var/lib/tomcat9/work /usr/share/tomcat9/work; \
        ln -sf /var/lib/tomcat9/temp /usr/share/tomcat9/temp; \
    fi

# Set working directory
WORKDIR /dspace-source

# Copy DSpace source code
COPY . .

# Build DSpace with proper module order
RUN export MAVEN_OPTS="-Xmx1g -Xms512m" && \
    cd dspace && \
    mvn clean package -DskipTests -Dcheckstyle.skip=true -Denforcer.skip=true -Dmaven.javadoc.skip=true -Dxml.skip=true -T 1C -P dspace-server-webapp -pl :server -am

# Check what was built and extract DSpace WAR
RUN mkdir -p /dspace/app && \
    echo "=== Checking build output ===" && \
    find . -name "*.war" -type f && \
    echo "=== Target directories ===" && \
    find . -name "target" -type d && \
    echo "=== DSpace directory structure ===" && \
    ls -la dspace/ && \
    echo "=== DSpace modules ===" && \
    ls -la dspace/modules/ && \
    echo "=== Server module target ===" && \
    ls -la dspace/modules/server/target/ && \
    echo "=== Copying and extracting WAR file ===" && \
    cp dspace/modules/server/target/*.war /dspace/app/dspace.war && \
    cd /dspace/app && \
    jar -xf dspace.war

# Create startup script
RUN echo '#!/bin/bash\n\
echo "Waiting for PostgreSQL..."\n\
while ! nc -z dspace-db 5432; do sleep 2; done\n\
echo "Waiting for Solr..."\n\
while ! nc -z dspace-solr 8983; do sleep 2; done\n\
echo "Starting DSpace Spring Boot application..."\n\
cd /dspace/app\n\
echo "Building classpath..."\n\
CLASSPATH="WEB-INF/classes"\n\
for jar in WEB-INF/lib/*.jar; do\n\
    CLASSPATH="$CLASSPATH:$jar"\n\
done\n\
echo "Classpath: $CLASSPATH"\n\
echo "Main class: org.dspace.app.ServerApplication"\n\
java -cp "$CLASSPATH" org.dspace.app.ServerApplication --server.port=8080\n\
' > /startup.sh && chmod +x /startup.sh

# Set working directory to DSpace app
WORKDIR /dspace/app

# Expose port
EXPOSE 8080

# Start DSpace
CMD ["/startup.sh"]
