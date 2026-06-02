module github.com/oliverhernandezmoreno/otel-microservices/services/go-service

go 1.20

require (
	go.opentelemetry.io/otel v1.17.0
	go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc v1.17.0
	go.opentelemetry.io/otel/sdk v1.17.0
	go.opentelemetry.io/otel/sdk/trace v1.17.0
)

require (
	github.com/golang/protobuf v1.5.3
	go.opentelemetry.io/otel/trace v1.17.0
	go.opentelemetry.io/proto/otlp v0.19.0
	google.golang.org/grpc v1.56.2
	google.golang.org/protobuf v1.31.0
)
