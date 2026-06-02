#!/bin/bash

echo "🚀 Generating test traffic..."

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

BASE_URL_NODE="http://localhost:3001"
BASE_URL_GO="http://localhost:8080"
BASE_URL_PYTHON="http://localhost:8000"

# Number of requests
NUM_REQUESTS=${1:-100}

echo "${BLUE}Sending $NUM_REQUESTS requests to each service${NC}"
echo ""

for i in $(seq 1 $NUM_REQUESTS); do
    # Node.js endpoints
    curl -s "$BASE_URL_NODE/api/users" > /dev/null 2>&1 &
    curl -s "$BASE_URL_NODE/health" > /dev/null 2>&1 &

    # Go endpoints
    curl -s "$BASE_URL_GO/api/products" > /dev/null 2>&1 &
    curl -s "$BASE_URL_GO/health" > /dev/null 2>&1 &

    # Python endpoints
    curl -s "$BASE_URL_PYTHON/api/orders" > /dev/null 2>&1 &
    curl -s "$BASE_URL_PYTHON/health" > /dev/null 2>&1 &

    if [ $((i % 10)) -eq 0 ]; then
        echo -ne "\r${GREEN}Processed: $i/$NUM_REQUESTS${NC}"
    fi
done

wait

echo -ne "\r${GREEN}✅ Completed: $NUM_REQUESTS/$NUM_REQUESTS${NC}\n"
echo ""
echo "${BLUE}View the traces at: http://localhost:16686${NC}"
echo "${BLUE}View the metrics at: http://localhost:3000${NC}"
