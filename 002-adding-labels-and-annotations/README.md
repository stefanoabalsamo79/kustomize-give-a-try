# Adding labels and annotation

In this lab we test how to propagate labels and annotation across multiple kubernetes resources:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
commonLabels:
  label1: label1 value
commonAnnotations:
  annotation1: annotation1 value
```

Looking at the output we will have labels and annotation propagated in each part of the manifest like the output below (shortened for sake a clarity):
```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    annotation1: annotation1 value
  labels:
    label1: label1 value
spec:
  selector:
    app: my-app-01
    label1: label1 value
---
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    annotation1: annotation1 value
    version: 1.0.0
  labels:
    label1: label1 value
  ...
spec:
  selector:
    matchLabels:
      app: my-app-01
      label1: label1 value
  template:
    metadata:
      annotations:
        annotation1: annotation1 value
      labels:
        app: my-app-01
        label1: label1 value
    ...
```