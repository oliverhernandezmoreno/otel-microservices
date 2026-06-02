.PHONY: help setup compose-up compose-down compose-logs k8s-deploy k8s-status k8s-logs k8s-delete clean health-check generate-traffic

help:
	@echo "OpenTelemetry Microservices Platform - Available Commands:"
	@echo ""
	@echo "Setup:"
	@echo "  make setup              - Install dependencies"
	@echo ""
	@echo "Docker Compose:"
	@echo "  make compose-up         - Start all services (Docker Compose)"
	@echo "  make compose-down       - Stop all services"
	@echo "  make compose-logs       - Show logs from all services"
	@echo "  make compose-minimal    - Start minimal stack"
	@echo ""
	@echo "Kubernetes:"
	@echo "  make k8s-deploy         - Deploy to Kubernetes"
	@echo "  make k8s-status         - Show deployment status"
	@echo "  make k8s-logs           - Show pod logs"
	@echo "  make k8s-delete         - Delete Kubernetes deployments"
	@echo ""
	@echo "Development:"
	@echo "  make health-check       - Check service health"
	@echo "  make generate-traffic   - Generate test traffic"
	@echo "  make clean              - Clean up resources"

setup:
	@echo "Setting up the platform..."
	cd services/nodejs-service && npm install
	cd ../go-service && go mod download
	cd ../python-service && pip install -r requirements.txt
	@echo "Setup completed!"

compose-up:
	@echo "Starting OpenTelemetry stack..."
	docker-compose up -d
	@sleep 5
	@echo "Stack is up!"
	@echo "Grafana: http://localhost:3000 (admin/admin)"
	@echo "Jaeger: http://localhost:16686"
	@echo "Prometheus: http://localhost:9090"

compose-minimal:
	@echo "Starting minimal stack (Jaeger + Prometheus)..."
	docker-compose -f docker-compose.minimal.yml up -d
	@sleep 3
	@echo "Minimal stack is up!"

compose-down:
	@echo "Stopping Docker Compose services..."
	docker-compose down

compose-logs:
	docker-compose logs -f

k8s-deploy:
	@echo "Deploying to Kubernetes..."
	kubectl create namespace otel-platform || true
	kubectl apply -f kubernetes/namespace.yaml
	kubectl apply -f kubernetes/configmaps/
	kubectl apply -f kubernetes/deployments/
	kubectl apply -f kubernetes/services/
	@echo "Kubernetes deployment completed!"

k8s-status:
	@echo "Kubernetes Deployments Status:"
	kubectl -n otel-platform get deployments,pods,svc

k8s-logs:
	@echo "Fetching logs from pods..."
	kubectl -n otel-platform logs -f deployment/collector --all-containers

k8s-delete:
	@echo "Deleting Kubernetes resources..."
	kubectl delete namespace otel-platform

health-check:
	@bash scripts/health-check.sh

generate-traffic:
	@bash scripts/generate-traffic.sh

clean:
	@echo "Cleaning up resources..."
	docker-compose down -v
	docker system prune -f
	@echo "Cleanup completed!"

.DEFAULT_GOAL := help
