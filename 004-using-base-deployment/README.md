# Using base deployment along with adding image and namespace

In this lab we try how use base deployment leveraging the `Kustomize` layer mechanism as well as setting `namespace` and `image/tag` to the manifests:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - base-deployment
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: application

images:
  - name: my-app-01
    newTag: 1.0.0

resources:
  - deployment.yaml
  - service.yaml
```

Run the make's `kustomize` target:
```bash
make kustomize LAB=004-using-base-deployment
```

Looking at the output, shortened for sake a clarity, we will have all the resources, deployment and service in this case, decorate with the namespace and the container image/tag. 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: test-service
  namespace: application # <-----
  ...
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: application # <-----
spec:
  ...
  template:
    spec:
      containers:
      - image: my-app-01:1.0.0 # <-----
        imagePullPolicy: IfNotPresent
        ...
```
