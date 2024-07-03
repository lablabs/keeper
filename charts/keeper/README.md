# keeper

Helm chart for capacity reservation and overprovisioning

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

## About
Keeper Helm chart. Deploys reservation and overprovisioning pods with optional schedules:
- **reservation**: Deploys lightweight pods that keep alive nodes specified in nodeSelector. Reservation relies on the ability to specify node size and resources in node labels, able to keep alive a node with certain size and properties. Each reservation pod keeps alive one node. Reservation affinity currently cannot be overridden.
- **overprovisioning**: Adds overprovisioning pods to the cluster. Size and number of overprovisioning pods can be modified. If real workload needs the resources occupied by an overprovisioning pod, the overprovisioning pod is evicted and if no free capacity is available, should trigger scaleup of a new node for the overprovisioning pod.

## Examples
### Reservation
The following values deploy 2 reservation deployments. `default` reserves 1 node of type c5d.xlarge, that is scaled to 1 Monday-Friday between 8-17 (Bratislava timeZone), and scaled down in the meantime. `unscheduled` reserves 2 nodes of type t3.large with no scheduled scaling.
```yaml
reservation:
  map:
    default:
      replicas: 1
      nodeSelector: |
        node.kubernetes.io/instance-type: c5d.xlarge
      schedule:
        timeZone: Europe/Bratislava
        up:
          cron: "0 8 * * 1-5"
          replicas: 1
        down:
          cron: "0 17 * * 1-5"
          replicas: 0
    unscheduled:
      replicas: 2
      nodeSelector: |
        node.kubernetes.io/instance-type: t3.large
```
### Overprovisioning
The following values deploy 1 overprovisioning deployment with 3 replicas which reserve 100 millicores and 500Mi of memory each. The deployment is scheduled Monday-Friday between 8-17. The replicas will be scheduled on any node available, and be evicted if real workload requires the capacity.
```yaml
overprovisioning:
  map:
    default:
      replicas: 3
      cpu: 100m
      memory: 500Mi
      schedule:
        up:
          cron: "0 8 * * 1-5"
          replicas: 3
        down:
          cron: "0 17 * * 1-5"
          replicas: 0
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| overprovisioning | object | `{"enabled":true,"image":"registry.k8s.io/pause:latest","imagePullPolicy":"Always","map":null,"priorityClass":{"create":true,"value":"-1000000"},"priorityClassOverride":""}` | Overprovisioning configuration |
| overprovisioning.enabled | bool | `true` | Whether overprovisioning is enabled |
| overprovisioning.image | string | `"registry.k8s.io/pause:latest"` | Overprovisioning image configuration |
| overprovisioning.imagePullPolicy | string | `"Always"` | Overprovisioning imagePullPolicy configuration |
| overprovisioning.map | string | `nil` | Map of overprovisioning deployments |
| overprovisioning.priorityClass | object | `{"create":true,"value":"-1000000"}` | Overprovisioning priorityClass configuration |
| overprovisioning.priorityClass.create | bool | `true` | Whether to create overprovisioning priorityClass |
| overprovisioning.priorityClass.value | string | `"-1000000"` | Overprovisioning priorityClass priority |
| overprovisioning.priorityClassOverride | string | `""` | Overprovisioning priorityClass name override, will be used instead of priorityClass created in overprovisioning.priorityClass |
| reservation | object | `{"enabled":true,"image":"registry.k8s.io/pause:3.9","imagePullPolicy":"Always","map":null}` | Reservation configuration |
| reservation.enabled | bool | `true` | Whether reservation is enabled |
| reservation.image | string | `"registry.k8s.io/pause:3.9"` | Reservation image configuration |
| reservation.imagePullPolicy | string | `"Always"` | Reservation image pull policy |
| reservation.map | string | `nil` | Map of reservation deployments |
| schedule | object | `{"concurrencyPolicy":"Replace","failedJobsHistoryLimit":1,"image":"bitnami/kubectl:latest","imagePullPolicy":"Always","resources":{"requests":{"cpu":"10m","memory":"32Mi"}},"successfulJobsHistoryLimit":1,"suspend":false}` | Schedule default values. Individual schedules are set in .Values.reservation.deployments[].schedule and .Values.overprovisioning.deployments[].schedule |
| schedule.concurrencyPolicy | string | `"Replace"` | Concurrency policy https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#concurrency-policy |
| schedule.failedJobsHistoryLimit | int | `1` | Number of failed Jobs to keep |
| schedule.image | string | `"bitnami/kubectl:latest"` | Schedule image configuration |
| schedule.imagePullPolicy | string | `"Always"` | Schedule image imagePullPolicy |
| schedule.resources | object | `{"requests":{"cpu":"10m","memory":"32Mi"}}` | Schedule resources |
| schedule.resources.requests | object | `{"cpu":"10m","memory":"32Mi"}` | Schedule resource requests |
| schedule.resources.requests.cpu | string | `"10m"` | Schedule cpu request |
| schedule.resources.requests.memory | string | `"32Mi"` | Schedule memory request |
| schedule.successfulJobsHistoryLimit | int | `1` | Number of successful Jobs to keep |
| schedule.suspend | bool | `false` | Set to true to suspend the CronJob |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service Account, ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations for service account. Evaluated as a template. Only used if `create` is `true`. |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `""` | Name of the service account to use. If not set and create is true, a name is generated using the fullname template. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
