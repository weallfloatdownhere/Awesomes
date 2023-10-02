# Awesomes
Awesome !

# Kubernetes

[k8s-bootstrapper](https://github.com/hivenetes/k8s-bootstrapper) Bootstrapping a Production-Ready DigitalOcean Kubernetes Cluster Using Terraform and Argo CD

## Kustomize

### Kustomize patches

#### Individual patch files

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ./argocd
patches:
- path: ./patch.argocd-cmd-params-cm.yaml
```

```yaml
# patch.argocd-cmd-params-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cmd-params-cm
  namespace: argocd
data:
  applicationsetcontroller.enable.progressive.syncs: "true"
```

#### Directly in the kustomization.yaml file

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: demo
resources:
- ../../base
patches:
  - target:
      version: v1
      group: apps
      kind: Deployment
      namespace: demo
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/env/0/value
        value: yellow
```

### Kustomize + Helm Charts

By Kustomize v4.1.0, a built-in support for a Helm generator has been added. So Kustomize can use the helm command to inflate charts as a resource generator (the Helm CLI is still needed).

The top-level helmCharts specification was introduced first, but it had some limitations. Later on (I think around v4.1.3), the built-in plugin added HelmChartInflationGenerator which is IMO the best way to work with Helm charts in Kustomize!

Here is and example:

```yaml
# helm-chart.yaml
apiVersion: builtin
kind: HelmChartInflationGenerator
metadata:
  name: my-map
name: minecraft
repo: https://kubernetes-charts.storage.googleapis.com
version: v1.2.0
releaseName: test
namespace: testNamespace
valuesFile: values.yaml
IncludeCRDs: true
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

generators:
- helm-chart.yaml
```

That's it! Let's render the chart:

```bash
kustomize build --enable-helm .
```

You will see the Helm chart resources rendered and you actually can customize them using Kustomize as normal!
