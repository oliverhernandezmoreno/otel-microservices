#!/bin/bash

echo "🧹 Cleaning up resources..."

# Stop Docker Compose
echo "Stopping Docker Compose services..."
docker-compose down -v

# Remove volumes
echo "Removing volumes..."
docker volume prune -f

# Clean up containers
echo "Removing stopped containers..."
docker container prune -f

echo "✅ Cleanup completed!"
