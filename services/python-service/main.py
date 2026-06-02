from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import os
import httpx
from contextlib import asynccontextmanager

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from prometheus_client import Counter, Histogram, REGISTRY, generate_latest

# OpenTelemetry Setup
resource = Resource.create({SERVICE_NAME: os.getenv("SERVICE_NAME", "python-service")})

otlp_exporter = OTLPSpanExporter(
    endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317")
)

tracer_provider = TracerProvider(resource=resource)
tracer_provider.add_span_processor(BatchSpanProcessor(otlp_exporter))
trace.set_tracer_provider(tracer_provider)

tracer = trace.get_tracer(__name__)

# Prometheus Metrics
http_request_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("✅ OpenTelemetry SDK initialized")
    FastAPIInstrumentor.instrument_app(app)
    HTTPXClientInstrumentor().instrument()
    yield
    tracer_provider.force_flush()

app = FastAPI(title="python-service", version="1.0.0", lifespan=lifespan)

# Health check
@app.get("/health")
async def health():
    return {"status": "healthy", "service": "python-service"}

# Metrics endpoint
@app.get("/metrics")
async def metrics():
    return generate_latest(REGISTRY)

# API Endpoints
@app.get("/api/orders")
async def get_orders():
    with tracer.start_as_current_span("GET /api/orders"):
        http_request_total.labels(method="GET", endpoint="/api/orders", status="200").inc()
        return {
            "orders": [
                {"id": 1, "product_id": 1, "quantity": 2, "price": 199.98},
                {"id": 2, "product_id": 2, "quantity": 1, "price": 149.99}
            ]
        }

@app.get("/api/orders/{order_id}")
async def get_order(order_id: int):
    with tracer.start_as_current_span(f"GET /api/orders/{order_id}"):
        return {"id": order_id, "product_id": 1, "quantity": 2, "price": 199.98}

@app.post("/api/orders")
async def create_order(order: dict):
    with tracer.start_as_current_span("POST /api/orders"):
        http_request_total.labels(method="POST", endpoint="/api/orders", status="201").inc()
        return {"id": 3, **order}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
