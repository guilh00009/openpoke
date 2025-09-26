#!/bin/bash

# OpenPoke Deployment Script
echo "🚀 Deploying OpenPoke with FriendliAI integration..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ docker-compose is not installed. Please install docker-compose (or enable the Docker Compose plugin) first."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
${COMPOSE_CMD} down

# Build and start the services
echo "🔨 Building and starting services..."
${COMPOSE_CMD} up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
if ${COMPOSE_CMD} ps | grep -q "Up"; then
    echo "✅ Deployment successful!"
    echo ""
    echo "🌐 Services are running:"
    echo "   - Server API: http://localhost:8001"
    echo "   - Web UI: http://localhost:3000"
    echo ""
    echo "📖 Check the logs with: ${COMPOSE_CMD} logs -f"
    echo "🛑 Stop with: ${COMPOSE_CMD} down"
else
    echo "❌ Deployment failed. Check the logs with: ${COMPOSE_CMD} logs"
fi
    echo "❌ Deployment failed. Check the logs with: docker-compose logs"
    exit 1
fi