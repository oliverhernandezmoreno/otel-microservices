# OpenTelemetry Microservices Platform

Arquitectura moderna de telemetría distribuida para monitorizar microservicios críticos en entornos cloud. Plataforma lista para implementar casos reales con soporte para Node.js, Go y Python.

## 🏗️ Arquitectura

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│   Node.js Svc       │     │    Go Service       │     │  Python Svc         │
└─────────────┬───────┘     └─────────────┬───────┘     └─────────────┬───────┘
              │                           │                           │
              └───────────────────────────┼───────────────────────────┘
                                          │ OTLP
                          ┌───────────────────────────┐
                          │  OpenTelemetry Collector  │
                          │  (gRPC + HTTP)            │
                          └───────┬─────────────┬─────┘
                                  │             │
                ┌─────────────────┼─────────────┼──────────────────┐
                │                 │             │                  │
                ▼                 ▼             ▼                  ▼
           ┌─────────────┐   ┌──────────────┐  ┌──────┐       ┌─────────────────┐
           │   Jaeger    │   │  Prometheus  │  │ Loki │       │   DataDog       │
           │  Tracing    │   │  Metrics     │  │ Logs │       │  (opcional)     │
           └────────┬────┘   └──────┬───────┘  └──┬───┘       └─────────────────┘
                    │               │             │
                    └───────────────┼─────────────┘
                                    │
                    ┌───────────────────────────────────┐
                    │     Grafana Dashboards            │
                    │   Alerts & Visualizations         │
                    └───────────────────────────────────┘
```

## 🚀 Características

✅ **OpenTelemetry SDK** completamente instrumentado  
✅ **Collector distribuido** con sampling inteligente  
✅ **Exporters múltiples**: Jaeger, Prometheus, Loki, DataDog  
✅ **Dashboards Grafana** preconfiguralizados  
✅ **Alertas automáticas** mediante Prometheus  
✅ **Docker Compose** para desarrollo local  
✅ **Kubernetes manifests** para producción  
✅ **Ejemplos de implementación** en 3 lenguajes  
✅ **Documentación completa** y guías paso a paso  

## 📋 Requisitos

- Docker & Docker Compose >= 20.10
- kubectl >= 1.24 (para Kubernetes)
- Node.js >= 18 | Go >= 1.20 | Python >= 3.9
- 4GB RAM mínimo para stack completo

## ⚡ Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/oliverhernandezmoreno/otel-microservices.git
cd otel-microservices
```

### 2. Ejecutar con Docker Compose

```bash
# Stack completo (Collector, Jaeger, Prometheus, Grafana, Loki)
docker-compose up -d

# Stack mínimo (solo Jaeger + Prometheus)
docker-compose -f docker-compose.minimal.yml up -d
```

### 3. Acceder a las interfaces

| Servicio | URL | Credenciales |
|----------|-----|---------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **Jaeger UI** | http://localhost:16686 | - |
| **Prometheus** | http://localhost:9090 | - |
| **Loki** | http://localhost:3100 | - |
| **Collector OTLP** | localhost:4317 (gRPC), localhost:4318 (HTTP) | - |

### 4. Generar tráfico de prueba

```bash
./scripts/generate-traffic.sh 100

# Ver trazas en Jaeger
open http://localhost:16686

# Ver métricas en Grafana
open http://localhost:3000
```

## 📁 Estructura del Proyecto

```
otel-microservices/
├── services/                    # Microservicios de ejemplo
│   ├── nodejs-service/
│   ├── go-service/
│   └── python-service/
├── otel-collector/              # Configuración del Collector
├── grafana/                     # Dashboards y provisioning
├── prometheus/                  # Configuración de Prometheus
├── kubernetes/                  # Manifiestos K8s
├── scripts/                     # Scripts de utilidad
├── docs/                        # Documentación
├── docker-compose.yml           # Stack completo
└── README.md
```

## 🔧 Comandos Útiles

```bash
# Ver help de comandos disponibles
make help

# Docker Compose
make compose-up              # Iniciar stack
make compose-down            # Detener stack
make compose-logs            # Ver logs

# Kubernetes
make k8s-deploy              # Deploy a K8s
make k8s-status              # Ver estado
make k8s-delete              # Eliminar resources

# Desarrollo
make health-check            # Verificar salud
make generate-traffic        # Generar tráfico de prueba
make clean                   # Limpiar todo
```

## 📚 Documentación

- **[SETUP.md](docs/SETUP.md)** - Guía de instalación
- **[INSTRUMENTATION.md](docs/INSTRUMENTATION.md)** - Cómo instrumentar aplicaciones
- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Deployment a producción
- **[CONFIGURATION.md](docs/CONFIGURATION.md)** - Configuración avanzada
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Resolución de problemas
- **[BEST_PRACTICES.md](docs/BEST_PRACTICES.md)** - Mejores prácticas

## 📞 Soporte

- 🐛 [Reportar bugs](https://github.com/oliverhernandezmoreno/otel-microservices/issues)
- 💡 [Sugerencias](https://github.com/oliverhernandezmoreno/otel-microservices/discussions)
- 🔄 [Pull Requests](https://github.com/oliverhernandezmoreno/otel-microservices/pulls)

## 📄 Licencia

MIT License - Ver [LICENSE](LICENSE) para detalles

---

**Creado por:** [Oliver Hernández Moreno](https://github.com/oliverhernandezmoreno)  
**Última actualización:** 2026-06-02
