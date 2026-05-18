# 02 — kubectl is a REST Client

## Purpose

Demonstrate that kubectl is an HTTP client sending REST API requests to the Kubernetes API server. Every `kubectl apply` is just a POST request.

## Demo

### Step 1 — Create a simple pod manifest

```bash
cat <<EOF > test-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-nginx
  namespace: default
spec:
  containers:
    - name: nginx
      image: nginx:alpine
EOF
```

### Step 2 — Apply with maximum verbosity

```bash
kubectl apply -f test-pod.yaml -v=8
```

Watch the output. You'll see lines like:

```
I0517 10:00:00.000000  12345 request.go:1234] Request Body: {"apiVersion":"v1","kind":"Pod",...}
I0517 10:00:00.000000  12345 round_trippers.go:466] POST https://kubernetes.docker.internal:6443/api/v1/namespaces/default/pods 201 Created
```

That's kubectl making an HTTP **POST** to the API server. The response is `201 Created`.

### Step 3 — Try GET and DELETE

```bash
# GET — retrieve the pod
kubectl get pod test-nginx -v=8

# DELETE — remove the pod
kubectl delete pod test-nginx -v=8
```

Every kubectl command maps to an HTTP method:
- `kubectl apply` → POST or PATCH
- `kubectl get` → GET
- `kubectl delete` → DELETE
- `kubectl edit` → GET + PUT

## What to observe

- kubectl reads your YAML, converts it to JSON, and sends it as an HTTP request body
- The API server URL, method, and response code are all visible
- This means any HTTP client (curl, CI/CD, operators) can manage Kubernetes
- Controllers, schedulers, and operators all use the same API

## Cleanup

```bash
kubectl delete pod test-nginx --ignore-not-found
rm test-pod.yaml
```
