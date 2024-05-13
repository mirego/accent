# Accent Helm Chart

# This Helm chart deploys [Accent](https://github.com/mirego/accent) on a Kubernetes cluster using the Helm package manager.
# It includes configuration for both Accent and a PostgreSQL database.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installing the Chart](#installing-the-chart)
- [Uninstalling the Chart](#uninstalling-the-chart)
- [Configuration](#configuration)
  - [Accent Configuration](#accent-configuration)
  - [PostgreSQL Configuration](#postgresql-configuration)
- [Usage](#usage)
  - [Accessing Accent](#accessing-accent)
  - [Connecting to PostgreSQL](#connecting-to-postgresql)
- [Customizing Your Deployment](#customizing-your-deployment)

## Introduction

# The Accent Helm chart provides an easy way to deploy the Accent application along with a PostgreSQL database to a Kubernetes cluster.
# Accent is an open-source tool to manage translations with ease, developed by Mirego.

## Prerequisites

# - A running Kubernetes cluster
# - `kubectl` command-line tool installed and configured
# - Helm installed and configured

## Installing the Chart

# To install the chart with the release name `my-release`:

helm install accent ./k8s/helm --create-namespace --namespace accent --values values.yaml

## Uninstalling the Chart

# To uninstall/delete the `my-release` deployment:

helm uninstall my-release

## Configuration

### Accent Configuration

# | Parameter                                   | Description                                         | Default                  |
# |---------------------------------------------|-----------------------------------------------------|--------------------------|
# | `accent.replicas`                           | Number of replicas for the Accent deployment        | `1`                      |
# | `accent.image.repository`                   | Accent image repository                             | `mirego/accent`          |
# | `accent.image.tag`                          | Accent image tag                                    | `latest`                 |
# | `accent.image.pullPolicy`                   | Image pull policy                                   | `Always`                 |
# | `accent.nameOverride`                       | Override for the Accent chart name                  | `""`                     |
# | `accent.fullnameOverride`                   | Override for the Accent full name                   | `""`                     |
# | `accent.podSecurityContext`                 | Pod security context                                | `{}`                     |
# | `accent.securityContext`                    | Container security context                          | `{}`                     |
# | `accent.service.name`                       | Accent service name                                 | `accent-service`         |
# | `accent.service.type`                       | Accent service type                                 | `ClusterIP`              |
# | `accent.service.port`                       | Accent service port                                 | `80`                     |
# | `accent.ingress.enabled`                    | Enable Ingress                                      | `false`                  |
# | `accent.ingress.className`                  | Ingress class name                                  | `nginx`                  |
# | `accent.ingress.pathType`                   | Ingress path type                                   | `ImplementationSpecific` |
# | `accent.ingress.annotations`                | Annotations for Ingress                             | `{}`                     |
# | `accent.ingress.hosts`                      | Hosts for Ingress                                   | `chart-example.local`    |
# | `accent.ingress.tls`                        | TLS configuration for Ingress                       | `[]`                     |
# | `accent.resources.limits.cpu`               | CPU resource limits                                 | `100m`                   |
# | `accent.resources.limits.memory`            | Memory resource limits                              | `128Mi`                  |
# | `accent.resources.requests.cpu`             | CPU resource requests                               | `100m`                   |
# | `accent.resources.requests.memory`          | Memory resource requests                            | `128Mi`                  |
# | `accent.configMap`                          | ConfigMap data for Accent                           | `{}`                     |
# | `accent.hpa.enabled`                        | Enable Horizontal Pod Autoscaler (HPA)              | `false`                  |
# | `accent.hpa.minReplicas`                    | Minimum number of replicas for HPA                  | `1`                      |
# | `accent.hpa.maxReplicas`                    | Maximum number of replicas for HPA                  | `100`                    |
# | `accent.hpa.targetCPUUtilizationPercentage` | Target CPU utilization percentage for HPA           | `80`                     |
# | `accent.hpa.targetMemoryUtilizationPercentage` | Target memory utilization percentage for HPA        | `80`                     |

### PostgreSQL Configuration

# | Parameter                       | Description                                      | Default          |
# |---------------------------------|--------------------------------------------------|------------------|
# | `postgresql.enabled`            | Enable PostgreSQL                                | `true`           |
# | `postgresql.replicas`           | Number of PostgreSQL replicas                    | `1`              |
# | `postgresql.image.repository`   | PostgreSQL image repository                      | `postgres`       |
# | `postgresql.image.tag`          | PostgreSQL image tag                             | `13`             |
# | `postgresql.image.pullPolicy`   | Image pull policy                                | `IfNotPresent`   |
# | `postgresql.nameOverride`       | Override for PostgreSQL chart name               | `""`             |
# | `postgresql.fullnameOverride`   | Override for PostgreSQL full name                | `""`             |
# | `postgresql.resources.limits.cpu` | CPU resource limits                             | `1000m`          |
# | `postgresql.resources.limits.memory` | Memory resource limits                         | `1024Mi`         |
# | `postgresql.resources.requests.cpu` | CPU resource requests                          | `1000m`          |
# | `postgresql.resources.requests.memory` | Memory resource requests                      | `1024Mi`         |
# | `postgresql.persistence.enabled` | Enable persistence for PostgreSQL               | `true`           |
# | `postgresql.persistence.size`   | Size of the persistence volume                   | `10Gi`           |
# | `postgresql.username`           | Username for PostgreSQL                          | `accentuser`     |
# | `postgresql.password`           | Password for PostgreSQL                          | `accentpass`     |
# | `postgresql.database`           | Database name for PostgreSQL                     | `accentdb`       |
# | `postgresql.service.name`       | PostgreSQL service name                          | `postgres-service` |
# | `postgresql.service.type`       | PostgreSQL service type                          | `ClusterIP`      |
# | `postgresql.service.port`       | PostgreSQL service port                          | `5432`           |

## Usage

### Accessing Accent

# After deploying the chart, you can access the Accent application based on the service type defined in the configuration:

# - **ClusterIP**:
#   - Connect to the service within your cluster using the service name and port.
#   - Use the following command to find the IP address of your Kubernetes cluster:

kubectl cluster-info

#   - Then, connect to the application using the internal IP and the service port.

# - **NodePort**:
#   - Find the NodePort assigned to your service:

kubectl get svc --namespace <your-namespace> -l "app.kubernetes.io/name=accent,app.kubernetes.io/instance=<your-release-name>"

#   - Connect using your node's IP address and the NodePort.

# - **LoadBalancer**:
#   - Watch the status of the LoadBalancer IP:

kubectl get svc --namespace <your-namespace> -l "app.kubernetes.io/name=accent,app.kubernetes.io/instance=<your-release-name>"

#   - Once the LoadBalancer IP is assigned, connect using the IP and the service port.

### Connecting to PostgreSQL

# If PostgreSQL is enabled, you can connect to your PostgreSQL database within your cluster using the following command:

kubectl run -it --rm --image=postgres:<postgresql-image-tag> --restart=Never pg-client -- psql -h <postgres-service-name> -U <postgres-username> -d <postgres-database>

# Replace `<postgresql-image-tag>`, `<postgres-service-name>`, `<postgres-username>`, and `<postgres-database>` with the appropriate values from your configuration.

## Customizing Your Deployment

# You can customize your deployment by modifying the `values.yaml` file and upgrading the Helm release:

helm upgrade accent ./k8s/helm --create-namespace --namespace accent --values values.yaml
