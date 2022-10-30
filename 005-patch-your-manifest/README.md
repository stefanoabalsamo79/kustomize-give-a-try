# Patch your manifest

In this lab we try how use the `Kustomize` patch mechanism via which you can target a specific part within your deployment and apply some changing to it such as adding, modifying and removing a certain section.
There are 2 kind of patching mechanism:
1. strategy merge patching (yaml based)
2. json patching (json based)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

patchesStrategicMerge: #(1)
  - patches/strategic-patch.yaml

patches: #(2)
  - path: patches/deployment-patch.json
    target:
      kind: Deployment
      name: my-app-01-deployment
```

**Strategy merge patching:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-01-deployment
  namespace: application
spec:
  template:
    spec:
      containers:
        - name: my-app-01
          resources:
            limits:
              cpu: 500m
              memory: 1G
            requests:
              cpu: 350m
              memory: 500M

```

**Json patching:**
```json
[
  { "op": "remove", "path": "/spec/strategy" },
  { "op": "replace", "path": "/spec/progressDeadlineSeconds", "value": 700 },
  { "op": "remove", "path": "/spec/template/spec/terminationGracePeriodSeconds" },
  { "op": "add", "path": "/spec/template/spec/terminationGracePeriodSeconds", "value": 45 } 
]
```

Run the make's `kustomize` target:
```bash
make kustomize LAB=005-patch-your-manifest
```

Looking at the output, not shortened this time for sake a clarity, we got the output where:
1. `spec.template.spec.containers[0].resources` has been updated 
2. `spec.strategy` has been removed from the manifest 
3. `spec.progressDeadlineSeconds` has been updated from `600` to `700`
4. `spec.template.spec.terminationGracePeriodSeconds` has been removed from the manifest 
5. `spec.template.spec.terminationGracePeriodSeconds` has been added again to the manifest now with `45` as its value

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
  progressDeadlineSeconds: 700 # <-----
  replicas: 1
  revisionHistoryLimit: 10
  # strategy no strategy any more
  selector:
    matchLabels:
      app: my-app-01
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
        resources: # <-----
          limits:
            cpu: 500m 
            memory: 1G
          requests:
            cpu: 350m 
            memory: 500M
      securityContext: {}
      terminationGracePeriodSeconds: 45 # <-----
```
