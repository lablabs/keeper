{{/*
Expand the name of the chart.
*/}}
{{- define "keeper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keeper.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default API prefix for ingress and networking purposes
*/}}
{{- define "keeper.apiPrefix" -}}
{{- if .Values.ingress.apiPrefix }}
{{- .Values.ingress.apiPrefix }}
{{- else }}
{{- (include "keeper.fullname" .) | replace "-" "_" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "keeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keeper.labels" -}}
helm.sh/chart: {{ include "keeper.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Reservation selector labels
*/}}
{{- define "keeper.reservation.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: reservation
{{- end }}

{{/*
Reservation labels
*/}}
{{- define "keeper.reservation.labels" -}}
{{ include "keeper.labels" . }}
{{ include "keeper.reservation.selectorLabels" . }}
{{- end }}

{{/*
Overprovisioning selector labels
*/}}
{{- define "keeper.overprovisioning.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: overprovisioning
{{- end }}

{{/*
Overprovisioning labels
*/}}
{{- define "keeper.overprovisioning.labels" -}}
{{ include "keeper.labels" . }}
{{ include "keeper.overprovisioning.selectorLabels" . }}
{{- end }}

{{/*
Schedule selector labels
*/}}
{{- define "keeper.schedule.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: schedule
{{- end }}

{{/*
Schedule labels
*/}}
{{- define "keeper.schedule.labels" -}}
{{ include "keeper.labels" . }}
{{ include "keeper.schedule.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keeper.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keeper.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
