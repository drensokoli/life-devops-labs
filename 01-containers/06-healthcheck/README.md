# 06 — Health Checks + Restart Policies Demo

## Purpose

Demonstrate how Docker health checks detect unhealthy containers and restart policies recover them automatically.

## Demo Steps

### 1. Build and run WITH health check + restart policy

```bash
docker build -t healthdemo .
docker run -d --name healthy-app --restart=on-failure:5 -p 8080:8080 healthdemo
```

### 2. Watch the container status

```bash
# In a separate terminal, watch status every 2s
watch -n 2 'docker ps --format "table {{.Names}}\t{{.Status}}"'
```

You'll see: `healthy-app   Up 10s (healthy)`

### 3. Tail the logs

```bash
docker logs -f healthy-app
```

### 4. Hit the visit endpoint (see logs stream)

```bash
curl http://localhost:8080/api/visit
curl http://localhost:8080/api/visit
curl http://localhost:8080/api/visit
```

### 5. Trigger unhealthy state

```bash
curl http://localhost:8080/crash
```

### 6. Watch the status change

In your `watch` terminal, you'll see:
- `(healthy)` → `(unhealthy)` after 3 failed checks (~15s)
- Docker restarts the container
- Status returns to `(health: starting)` → `(healthy)`

### 7. Compare: run WITHOUT health check

```bash
docker build -f Dockerfile.no-health -t healthdemo-no-check .
docker run -d --name no-check-app --restart=on-failure:5 -p 8081:8080 healthdemo-no-check

# Crash it
curl http://localhost:8081/crash

# Docker has no idea it's broken — status stays "Up" forever
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### 8. Clean up

```bash
docker stop healthy-app no-check-app
docker rm healthy-app no-check-app
```
