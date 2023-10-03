# Awesomes
Awesome !

# Bash

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

### Generic kubernetes deploy script based on olm

[Reference](https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.25.0/install.sh)

```bash
#!/usr/bin/env bash


# This script is for installing OLM from a GitHub release

set -e

default_base_url=https://github.com/operator-framework/operator-lifecycle-manager/releases/download

if [[ ${#@} -lt 1 || ${#@} -gt 2 ]]; then
    echo "Usage: $0 version [base_url]"
    echo "* version: the github release version"
    echo "* base_url: the github base URL (Default: $default_base_url)"
    exit 1
fi

if kubectl get deployment olm-operator -n openshift-operator-lifecycle-manager > /dev/null 2>&1; then
    echo "OLM is already installed in a different configuration. This is common if you are not running a vanilla Kubernetes cluster. Exiting..."
    exit 1
fi

release="$1"
base_url="${2:-${default_base_url}}"
url="${base_url}/${release}"
namespace=olm

if kubectl get deployment olm-operator -n ${namespace} > /dev/null 2>&1; then
    echo "OLM is already installed in ${namespace} namespace. Exiting..."
    exit 1
fi

kubectl create -f "${url}/crds.yaml"
kubectl wait --for=condition=Established -f "${url}/crds.yaml"
kubectl create -f "${url}/olm.yaml"

# wait for deployments to be ready
kubectl rollout status -w deployment/olm-operator --namespace="${namespace}"
kubectl rollout status -w deployment/catalog-operator --namespace="${namespace}"

retries=30
until [[ $retries == 0 ]]; do
    new_csv_phase=$(kubectl get csv -n "${namespace}" packageserver -o jsonpath='{.status.phase}' 2>/dev/null || echo "Waiting for CSV to appear")
    if [[ $new_csv_phase != "$csv_phase" ]]; then
        csv_phase=$new_csv_phase
        echo "Package server phase: $csv_phase"
    fi
    if [[ "$new_csv_phase" == "Succeeded" ]]; then
	break
    fi
    sleep 10
    retries=$((retries - 1))
done

if [ $retries == 0 ]; then
    echo "CSV \"packageserver\" failed to reach phase succeeded"
    exit 1
fi

kubectl rollout status -w deployment/packageserver --namespace="${namespace}"

```
