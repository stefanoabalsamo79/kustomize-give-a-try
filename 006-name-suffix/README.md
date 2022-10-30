# Name suffix

In this lab we name try the name suffixing mechanism which can be very useful to differentiate resource.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

nameSuffix: -some-suffix

resources:
  - deployment.yaml
  - service.yaml

```

Run the make's `kustomize` target:
```bash
make kustomize LAB=006-name-suffix
```
Having a look at the output, shortened for the sake of clarity, we can see that the manifest we got presents each resources' name with the suffix we declared in the kustomization.yaml file (i.e. `nameSuffix: -some-suffix`)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: test-service-some-suffix # <---
...
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-01-deployment-some-suffix # <---
  namespace: application
...

```
