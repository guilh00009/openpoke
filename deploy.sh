#!/bin/bash

# OpenPoke Deployment Script
echo "🚀 Deploying OpenPoke with FriendliAI integration..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install docker-compose first."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Build and start the services
echo "🔨 Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Deployment successful!"
    echo ""
    echo "🌐 Services are running:"
    echo "   - Server API: http://localhost:8001"
    echo "   - Web UI: http://localhost:3000"
    echo ""
    echo "📖 Check the logs with: docker-compose logs -f"
    echo "🛑 Stop with: docker-compose down"
else
    echo "❌ Deployment failed. Check the logs with: docker-compose logs"
    exit 1
fi