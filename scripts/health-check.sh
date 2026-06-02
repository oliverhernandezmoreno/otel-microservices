#!/bin/bash

echo "🔍 Health Check - OpenTelemetry Platform"
echo "========================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_service() {
    local name=$1
    local url=$2
    echo -n "Checking $name... "
    if curl -sf "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

echo ""
echo "📊 Infrastructure Services:"
check_service "Prometheus" "http://localhost:9090/-/healthy"
check_service "Grafana" "http://localhost:3000/api/health"
check_service "Jaeger" "http://localhost:16686"
check_service "Loki" "http://localhost:3100/ready"
check_service "OTLP Collector" "http://localhost:8888/metrics"

echo ""
echo "========================================"
echo "✅ Health check completed"
