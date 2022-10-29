# First example

In this first example we have a basic [`kustomize`](./k8s/kustomization.yaml) config:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

using the following resources:
* [`deployment.yaml`](./k8s/deployment.yaml)
* [`service.yaml`](./k8s/service.yaml)

so we use kustomize cli output as input for kubectl apply, for instance:
```shell	
  kustomize build ./001-first-example/k8s | kubectl delete -n application -f - 
```  

The output will be a union of the two resources declared within the `Kustomization` resources, the something like that:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: test-service
  namespace: application
spec:
  ports:
  - name: http
    port: 3000
    protocol: TCP
    targetPort: 3000
  selector:
    app: my-app-01
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    version: 1.0.0
  name: my-app-01-deployment
  namespace: application
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: my-app-01
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: my-app-01
    spec:
      containers:
      - image: my-app-01:1.0.0
        imagePullPolicy: IfNotPresent
        name: my-app-01
        ports:
        - containerPort: 3000
          protocol: TCP
        resources:
          limits:
            cpu: 300m
            memory: 1G
          requests:
            cpu: 200m
            memory: 500M
      securityContext: {}
      terminationGracePeriodSeconds: 30
```


