require('./otel-init');

const express = require('express');
const client = require('prom-client');
const { trace } = require('@opentelemetry/api');

const app = express();
const PORT = process.env.PORT || 3001;
const tracer = trace.getTracer('nodejs-service');

const httpRequestTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'nodejs-service' });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.get('/api/users', (req, res) => {
  const span = tracer.startSpan('GET /api/users');
  try {
    httpRequestTotal.labels('GET', '/api/users', 200).inc();
    res.json({
      users: [
        { id: 1, name: 'Alice', email: 'alice@example.com' },
        { id: 2, name: 'Bob', email: 'bob@example.com' },
      ],
    });
  } finally {
    span.end();
  }
});

app.post('/api/users', (req, res) => {
  const span = tracer.startSpan('POST /api/users');
  try {
    httpRequestTotal.labels('POST', '/api/users', 201).inc();
    res.status(201).json({
      id: 3,
      name: req.body.name || 'New User',
      email: req.body.email || 'new@example.com',
    });
  } finally {
    span.end();
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Node.js service running on port ${PORT}`);
  console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
  console.log(`❤️ Health check at http://localhost:${PORT}/health`);
});
