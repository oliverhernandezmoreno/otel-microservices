package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"go.opentelemetry.io/otel"
)

func main() {
	tp := InitProvider("go-service")
	defer func() {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := tp.Shutdown(ctx); err != nil {
			fmt.Println("Error shutting down tracer provider:", err)
		}
	}()

	tracer := otel.Tracer("go-service")

	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy","service":"go-service"}`))
	})

	// Metrics endpoint
	mux.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("# HELP go_service_requests_total Total requests\n"))
		w.Write([]byte("# TYPE go_service_requests_total counter\n"))
		w.Write([]byte("go_service_requests_total{method=\"GET\",path=\"/api/products\"} 42\n"))
	})

	// API endpoints
	mux.HandleFunc("/api/products", func(w http.ResponseWriter, r *http.Request) {
		ctx, span := tracer.Start(context.Background(), "GET /api/products")
		defer span.End()

		span.AddEvent("Fetching products from database")

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{
  "products": [
    {"id": 1, "name": "Product A", "price": 99.99},
    {"id": 2, "name": "Product B", "price": 149.99}
  ]
}`))

		span.AddEvent("Successfully returned products")
	})

	mux.HandleFunc("/api/products/1", func(w http.ResponseWriter, r *http.Request) {
		ctx, span := tracer.Start(context.Background(), "GET /api/products/1")
		defer span.End()

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"id": 1, "name": "Product A", "price": 99.99}`))
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("🚀 Go service running on port %s\n", port)
	fmt.Printf("📊 Metrics available at http://localhost:%s/metrics\n", port)
	fmt.Printf("❤️  Health check at http://localhost:%s/health\n", port)

	if err := http.ListenAndServe(":"+port, mux); err != nil {
		fmt.Println("Error starting server:", err)
	}
}
