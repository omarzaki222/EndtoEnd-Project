#!/bin/bash

# Configure Docker Access for Jenkins Container
# This script helps configure Docker access when Jenkins is running in a container

set -e

echo "🐳 Configuring Docker Access for Jenkins Container"
echo "================================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is installed and running"

# Check if Jenkins is running in a container
JENKINS_CONTAINER=$(docker ps --filter "name=jenkins" --format "{{.Names}}" | head -1)

if [ -n "$JENKINS_CONTAINER" ]; then
    echo "🔍 Found Jenkins container: $JENKINS_CONTAINER"
    
    # Check if Jenkins container has Docker socket mounted
    if docker inspect $JENKINS_CONTAINER | grep -q "/var/run/docker.sock"; then
        echo "✅ Docker socket is already mounted in Jenkins container"
    else
        echo "⚠️  Docker socket is not mounted in Jenkins container"
        echo ""
        echo "📋 To fix this, you need to restart Jenkins container with Docker socket mounted:"
        echo ""
        echo "1. Stop the current Jenkins container:"
        echo "   docker stop $JENKINS_CONTAINER"
        echo ""
        echo "2. Start Jenkins with Docker socket mounted:"
        echo "   docker run -d --name jenkins \\"
        echo "     -p 8080:8080 -p 50000:50000 \\"
        echo "     -v /var/run/docker.sock:/var/run/docker.sock \\"
        echo "     -v jenkins_home:/var/jenkins_home \\"
        echo "     jenkins/jenkins:lts"
        echo ""
        echo "   Or if using docker-compose, add to your docker-compose.yml:"
        echo "   volumes:"
        echo "     - /var/run/docker.sock:/var/run/docker.sock"
    fi
    
    # Check if Jenkins container has Docker binary
    if docker exec $JENKINS_CONTAINER which docker &> /dev/null; then
        echo "✅ Docker binary is available in Jenkins container"
    else
        echo "⚠️  Docker binary is not available in Jenkins container"
        echo ""
        echo "📋 To fix this, you can:"
        echo "1. Use a Jenkins image that includes Docker (e.g., jenkins/jenkins:lts-jdk11)"
        echo "2. Install Docker inside the Jenkins container"
        echo "3. Use Docker-in-Docker (DinD) approach"
    fi
    
else
    echo "⚠️  No Jenkins container found"
    echo "   This script is designed for Jenkins running in Docker containers"
    echo "   If Jenkins is installed directly on the host, use the regular install-docker.sh script"
fi

echo ""
echo "🔧 Alternative Solutions:"
echo ""
echo "1. **Docker-in-Docker (DinD)**: Use a Jenkins agent with Docker-in-Docker"
echo "2. **Remote Docker Host**: Configure Jenkins to use a remote Docker host"
echo "3. **Docker Pipeline Plugin**: Use Jenkins Docker Pipeline plugin"
echo ""
echo "📚 For more details, see DOCKER_TROUBLESHOOTING.md"
