# 01 — Image Layers Demo

## Purpose

Demonstrate how Docker images are built from layers and how caching works.

## Commands

```bash
# Pull an image and inspect its layers
docker pull nginx:alpine
docker history nginx:alpine

# Pull a larger image to compare
docker pull mcr.microsoft.com/dotnet/sdk:8.0
docker history mcr.microsoft.com/dotnet/sdk:8.0

# Compare image sizes
docker images | grep -E "nginx|dotnet"
```

## What to observe

- Each row in `docker history` is a layer
- Some layers are tiny (metadata), some are large (package installs)
- `<missing>` means intermediate layers from the base are squashed
- The SDK image is much larger than nginx:alpine
