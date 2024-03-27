# Accent Helm Chart

This Helm chart deploys [Accent](https://github.com/mirego/accent) on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.1.0

## Installing the Chart

To install the chart with the release name `accent`:

```bash
helm upgrade accent ./k8s/helm --namespace accent --create-namespace --install
```

This command deploys Accent on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `accent` deployment:

```
bash
helm delete accent
```

## Parameters

The following table lists the configurable parameters of the Accent chart and their default values.

| Parameter                                  | Description                                      | Default                                       |
|--------------------------------------------|--------------------------------------------------|-----------------------------------------------|
| `replicaCount`                             | Number of replicas                               | `1`                                           |
| `image.repository`                         | Image repository                                 | `mirego/accent`                               |
| `image.tag`                                | Image tag                                        | `latest`                                      |
| `image.pullPolicy`                         | Image pull policy                                | `Always`                                      |
| `nameOverride`                             | Override name                                    | `""`                                          |
| `fullnameOverride`                         | Override full name                               | `""`                                          |
| `podSecurityContext`                       | Pod security context settings                    | `{}`                                          |
| `securityContext`                          | Security context settings for the container      | `{}`                                          |
| `livenessProbe`                            | Liveness probe settings                          | `{ httpGet, initialDelaySeconds, ... }`       |
| `readinessProbe`                           | Readiness probe settings                         | `{ httpGet, initialDelaySeconds, ... }`       |
| `service.type`                             | Service type                                     | `ClusterIP`                                   |
| `service.port`                             | Service port                                     | `80`                                          |
| `ingress.enabled`                          | If ingress is enabled                            | `true`                                        |
| `ingress.className`                        | Ingress class name                               | `nginx`                                       |
| `ingress.annotations`                      | Ingress annotations                              | `{}`                                          |
| `ingress.pathType`                         | Ingress path type                                | `ImplementationSpecific`                      |
| `ingress.hosts`                            | Hosts for ingress                                | `[ { host: chart-example.local, paths: / } ]` |
| `ingress.tls`                              | TLS configuration for ingress                    | `[]`                                          |
| `resources.limits.cpu`                     | CPU limit for the pod                            | `100m`                                        |
| `resources.limits.memory`                  | Memory limit for the pod                         | `128Mi`                                       |
| `resources.requests.cpu`                   | CPU request for the pod                          | `100m`                                        |
| `resources.requests.memory`                | Memory request for the pod                       | `128Mi`                                       |
| `hpa.enabled`                              | If HPA is enabled                                | `false`                                       |
| `configMap`                                | Configuration in ConfigMap                       | `{}`                                          |
| `hpa.minReplicas`                          | Minimum number of replicas for HPA               | `1`                                           |
| `hpa.maxReplicas`                          | Maximum number of replicas for HPA               | `100`                                         |
| `hpa.targetCPUUtilizationPercentage`       | Target CPU utilization percentage for HPA        | `80`                                          |
| `hpa.targetMemoryUtilizationPercentage`    | Target memory utilization percentage for HPA     | `80`                                          |

## Configuration

Refer to `values.yaml` for the full run-down on defaults. These are YAML files that contain the default configuration settings.

## Customizing the Chart Before Installing

To edit or add to the predefined `values.yaml`, you can use:

```bash
helm show values ./k8s/helm > my-values.yaml
vim my-values.yaml
```

Then, to install the chart with the release name `accent` and custom values:

```bash
helm upgrade accent ./k8s/helm --namespace accent --create-namespace --install --values my-values.yaml
```
