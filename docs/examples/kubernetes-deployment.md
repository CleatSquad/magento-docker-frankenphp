# Example: Kubernetes Deployment

This example shows how to deploy Magento with FrankenPHP to a Kubernetes cluster.

## Prerequisites

- A Kubernetes cluster (EKS, GKE, AKS, or self-hosted)
- kubectl configured
- A container registry with your Magento image

## Configuration Files

### 1. Namespace

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: magento
```

### 2. ConfigMap for Environment Variables

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: magento-config
  namespace: magento
data:
  SERVER_NAME: "magento.example.com"
  MAGENTO_RUN_MODE: "production"
```

### 3. Secret for Sensitive Data

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: magento-secrets
  namespace: magento
type: Opaque
stringData:
  DB_HOST: "mysql-service"
  DB_NAME: "magento"
  DB_USER: "magento"
  DB_PASSWORD: "your-secure-password"
  ADMIN_PASSWORD: "your-admin-password"
```

### 4. Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: magento-app
  namespace: magento
  labels:
    app: magento
spec:
  replicas: 3
  selector:
    matchLabels:
      app: magento
  template:
    metadata:
      labels:
        app: magento
    spec:
      containers:
        - name: magento
          image: your-registry/magento-frankenphp:latest
          ports:
            - containerPort: 80
              name: http
            - containerPort: 443
              name: https
          envFrom:
            - configMapRef:
                name: magento-config
            - secretRef:
                name: magento-secrets
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "2000m"
          readinessProbe:
            httpGet:
              path: /health_check.php
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health_check.php
              port: 80
            initialDelaySeconds: 60
            periodSeconds: 30
          volumeMounts:
            - name: media-storage
              mountPath: /var/www/html/pub/media
      volumes:
        - name: media-storage
          persistentVolumeClaim:
            claimName: magento-media-pvc
```

### 5. Service

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: magento-service
  namespace: magento
spec:
  selector:
    app: magento
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
    - name: https
      protocol: TCP
      port: 443
      targetPort: 443
  type: ClusterIP
```

### 6. Ingress (with TLS)

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: magento-ingress
  namespace: magento
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - magento.example.com
      secretName: magento-tls
  rules:
    - host: magento.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: magento-service
                port:
                  number: 80
```

### 7. Persistent Volume Claim for Media

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: magento-media-pvc
  namespace: magento
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: standard
  resources:
    requests:
      storage: 50Gi
```

## Deployment Commands

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Create ConfigMap and Secret
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

# Create PVC
kubectl apply -f pvc.yaml

# Deploy application
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Check deployment status
kubectl -n magento get pods
kubectl -n magento get services
kubectl -n magento get ingress
```

## Horizontal Pod Autoscaler (HPA)

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: magento-hpa
  namespace: magento
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: magento-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

## Tips

1. **Caching**: Use Redis or Valkey for session and cache storage (deployed as separate services)
2. **Database**: Deploy MariaDB or MySQL as a StatefulSet or use a managed database service
3. **Search**: Deploy OpenSearch as a StatefulSet or use a managed service
4. **CDN**: Consider using a CDN for static assets
5. **Monitoring**: Set up Prometheus and Grafana for monitoring
