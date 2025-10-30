# keeper

Helm chart for node capacity reservation and overprovisioning

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

## About
Keeper Helm chart. Deploys node reservation and overprovisioning placeholder pods with optional schedules:
- **reservation**: Deploys lightweight pods that keep alive nodes specified in nodeSelector. Reservation relies on the ability to specify node size and resources in node labels, able to keep alive a node with certain size and properties. Each reservation pod keeps alive one node. Reservation affinity currently cannot be overridden.
- **overprovisioning**: Deploys overprovisioning pods to the cluster. Size and number of overprovisioning pods can be modified. If real workload needs the resources occupied by an overprovisioning pod, the overprovisioning pod is evicted and if no free capacity is available, should trigger scaleup of a new node for the overprovisioning pod.

### Schedule
Each reservation and overprovisioning placeholder can be scheduled up and down to a desired number of replicas to account e.g. for peak times or working hours.

> [!WARNING]
> When enabling schedules for a placeholder, replicas revert to 1, no matter the current replicas, and are then updated when the next schedule CronJob runs.
> To apply the value that should be valid at the time of the apply, manually trigger the corresponding schedule CronJob.

## Examples
### Reservation
The following values deploy 2 reservation deployments. `default` reserves 1 node of type c5d.xlarge, that is scaled to 1 Monday-Friday between 8-17 (Bratislava timeZone), and scaled down in the meantime. `unscheduled` reserves 2 nodes of type t3.large with no scheduled scaling.
```yaml
reservation:
  placeholders:
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
  placeholders:
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
| commonLabels | object | `{}` | Common labels for all resources, ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| fullnameOverride | string | `""` | String to fully override app.fullname template |
| nameOverride | string | `""` | String to partially override app.fullname template (will maintain the release name) |
| overprovisioning | object | `{"enabled":true,"image":"registry.k8s.io/pause:3.10.1","imagePullPolicy":"Always","placeholders":{},"priorityClass":{"create":true,"value":"-1000000"},"priorityClassOverride":"","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false}}` | Overprovisioning configuration |
| overprovisioning.enabled | bool | `true` | Whether overprovisioning is enabled |
| overprovisioning.image | string | `"registry.k8s.io/pause:3.10.1"` | Overprovisioning image configuration |
| overprovisioning.imagePullPolicy | string | `"Always"` | Overprovisioning imagePullPolicy configuration |
| overprovisioning.placeholders | object | `{}` | Map of overprovisioning placeholder deployments |
| overprovisioning.priorityClass | object | `{"create":true,"value":"-1000000"}` | Overprovisioning PriorityClass configuration |
| overprovisioning.priorityClass.create | bool | `true` | Whether to create overprovisioning PriorityClass |
| overprovisioning.priorityClass.value | string | `"-1000000"` | Overprovisioning PriorityClass priority |
| overprovisioning.priorityClassOverride | string | `""` | Overprovisioning PriorityClass name, set to use instead of PriorityClass created via overprovisioning.priorityClass |
| overprovisioning.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false}` | Container Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod |
| podLabels | object | `{}` | Pod labels, ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| reservation | object | `{"enabled":true,"image":"registry.k8s.io/pause:3.10.1","imagePullPolicy":"Always","placeholders":{},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false}}` | Reservation configuration |
| reservation.enabled | bool | `true` | Whether reservation is enabled |
| reservation.image | string | `"registry.k8s.io/pause:3.10.1"` | Reservation image configuration |
| reservation.imagePullPolicy | string | `"Always"` | Reservation image pull policy |
| reservation.placeholders | object | `{}` | Map of reservation placeholder deployments |
| reservation.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false}` | Container Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod |
| schedule | object | `{"concurrencyPolicy":"Replace","failedJobsHistoryLimit":1,"image":"ghcr.io/lablabs/kubectl:latest","imagePullPolicy":"Always","resources":{"requests":{"cpu":"10m","memory":"32Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false},"successfulJobsHistoryLimit":1,"suspend":false}` | Schedule default values. Individual schedules are set in .Values.reservation.deployments[].schedule and .Values.overprovisioning.deployments[].schedule |
| schedule.concurrencyPolicy | string | `"Replace"` | Concurrency policy https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#concurrency-policy |
| schedule.failedJobsHistoryLimit | int | `1` | Number of failed Jobs to keep |
| schedule.image | string | `"ghcr.io/lablabs/kubectl:latest"` | Schedule image configuration |
| schedule.imagePullPolicy | string | `"Always"` | Schedule image imagePullPolicy |
| schedule.resources | object | `{"requests":{"cpu":"10m","memory":"32Mi"}}` | Schedule resources |
| schedule.resources.requests | object | `{"cpu":"10m","memory":"32Mi"}` | Schedule resource requests |
| schedule.resources.requests.cpu | string | `"10m"` | Schedule cpu request |
| schedule.resources.requests.memory | string | `"32Mi"` | Schedule memory request |
| schedule.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false}` | Container Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod |
| schedule.successfulJobsHistoryLimit | int | `1` | Number of successful Jobs to keep |
| schedule.suspend | bool | `false` | Set to true to suspend the CronJob |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service Account, ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | Annotations for service account. Evaluated as a template. Only used if `create` is `true`. |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `""` | Name of the service account to use. If not set and create is true, a name is generated using the fullname template. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
