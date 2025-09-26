#!/bin/bash

# OpenPoke Deployment Script
echo "🚀 Deploying OpenPoke with FriendliAI integration..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "📝 Please copy .env.example to .env and configure your API keys:"
    echo "   cp .env.example .env"
    echo "   # Then edit .env with your actual credentials"
    echo ""
    echo "🔄 Continuing with default configuration (you may need to configure API keys manually)..."
fi

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
if [ -f ".env" ]; then
    ${COMPOSE_CMD} --env-file .env up --build -d
else
    ${COMPOSE_CMD} up --build -d
fi

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 15

# Check if services are running
if ${COMPOSE_CMD} ps | grep -q "Up"; then
    echo "✅ Deployment successful!"
    echo ""
    echo "🌐 Services are running:"
    echo "   - Server API: http://localhost:8001"
    echo "   - Web UI: http://localhost:3000"
    echo ""
    echo "📖 Check the logs with: ${COMPOSE_CMD} logs -f"
    echo "🔍 View service status: ${COMPOSE_CMD} ps"
    echo "🛑 Stop with: ${COMPOSE_CMD} down"
    echo ""
    echo "💡 Tip: If you encounter API key issues, edit your .env file with correct credentials"
else
    echo "❌ Deployment failed. Check the logs with: ${COMPOSE_CMD} logs"
    echo ""
    echo "🔧 Troubleshooting tips:"
    echo "   1. Check if your .env file has valid API keys"
    echo "   2. Verify Docker has enough resources"
    echo "   3. Check firewall settings"
    exit 1
fi