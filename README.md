# Awesomes
Awesome !

# Terraform

## [Providers](https://github.com/topics/terraform-provider)

 - [ArgoCD provider](https://registry.terraform.io/providers/oboukili/argocd/latest/docs)

# Bash

Quickly test if a string contains a certain word

```bash
echo http://bitbucket.org | grep github ; echo $?
```

Recursively find each directory named '.hooks' inside a git repository, then run every script found in them taking care of not executing itself if the script happens to be in a '.hooks' directory itself.

```bash
for hookdir in "$(find $(git rev-parse --show-toplevel)/ -name ".hooks" -type d)" ; do
  for hookscript in $hookdir/*; do
    if [[ "$(basename ${0})" != "$(basename $hookscript)" ]]; then
      $hookscript;
    fi
  done
done
```

Generate a new admin account for argocd using bash

```bash
#!/bin/bash
export TARGET_CTX=k3s-ontario-edge-1
export ARGOCD_CTX=argo-hub

cat <<EOF | kubectl apply --context $TARGET_CTX -n kube-system  -f -
apiVersion: v1
kind: Secret
metadata:
  name: argocd-manager-token
  namespace: kube-system 
  annotations:
    kubernetes.io/service-account.name: argocd-manager
type: kubernetes.io/service-account-token
EOF

name="argocd-manager-token"
token=$(kubectl get --context $TARGET_CTX -n kube-system secret/$name -o jsonpath='{.data.token}' | base64 --decode)
namespace=$(kubectl get --context $TARGET_CTX -n kube-system secret/$name -o jsonpath='{.data.namespace}' | base64 --decode)

cat <<EOF | kubectl apply --context $ARGOCD_CTX -n argocd -f -
apiVersion: v1
kind: Secret
metadata:
  name: ontario
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: ontario-tunnel-inlets-pro-data-plane
  server: https://ontario-tunnel-inlets-pro-data-plane:443
  config: |
    {
      "bearerToken": "${token}",
      "tlsClientConfig": {
        "serverName": "kubernetes.default.svc"
      }
    }
EOF
```

Add an annotation with the value: argocd.argoproj.io/sync-wave="VALUE" to each yaml file found in a git repository.

```bash
for d in "$(git rev-parse --show-toplevel)/*" ; do
  for FILE in $d/*; do
    VALUE='"'VALUE'"' yq -i e '.metadata.annotations.["argocd.argoproj.io/sync-wave"] = env(VALUE)' $FILE;
  done
done
```

# Kubernetes

[k8s-bootstrapper](https://github.com/hivenetes/k8s-bootstrapper) Bootstrapping a Production-Ready DigitalOcean Kubernetes Cluster Using Terraform and Argo CD

## Helm

Iterrate throught range

```yaml
spec:
  rules:
  {{- range $key, $value := .Values.global.ingress }}
  {{- range $value.hosts }}
  - host: {{ . }}
    http:
      paths:
      - path: /qapi
        backend:
          serviceName: api-server
          servicePort: 80
  {{- end }}
  {{- end }}
```

## Kustomize

### Kustomize patches

[Kustomize HelmCharts documentation](https://kubectl.docs.kubernetes.io/references/kustomize/builtins/#field-name-helmcharts)

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

```golang
func makeHelmChartFromHca(old *HelmChartArgs) (c HelmChart) {
	c.Name = old.ChartName
	c.Version = old.ChartVersion
	c.Repo = old.ChartRepoURL
	c.ValuesFile = old.Values
	c.ValuesInline = old.ValuesLocal
	c.ValuesMerge = old.ValuesMerge
	c.ReleaseName = old.ReleaseName
	return
}
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
