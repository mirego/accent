{{/* Expand the name of the chart for Accent. */}}
{{- define "accent.name" -}}
{{- default .Chart.Name .Values.accent.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/* Expand the name of the chart for PostgreSQL. */}}
{{- define "postgres.name" -}}
{{- default "postgres" .Values.postgres.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/* Create a default fully qualified app name for Accent. */}}
{{- define "accent.fullname" -}}
{{- if .Values.accent.fullnameOverride }}
{{- .Values.accent.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.accent.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Create a default fully qualified app name for Postgres. */}}
{{- define "postgres.fullname" -}}
{{- if .Values.postgres.fullnameOverride }}
{{- .Values.postgres.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "postgres" .Values.postgres.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Generate basic labels for Accent. */}}
{{- define "accent.labels" -}}
helm.sh/chart: {{ include "accent.chart" . }}
app.kubernetes.io/name: {{ include "accent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Generate basic labels for Postgres. */}}
{{- define "postgres.labels" -}}
helm.sh/chart: {{ include "postgres.chart" . }}
app.kubernetes.io/name: {{ include "postgres.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Generate selector labels for Accent. */}}
{{- define "accent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "accent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Generate selector labels for PostgreSQL. */}}
{{- define "postgres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgres.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Define chart name and version for accent. */}}
{{- define "accent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end }}

{{/* Define chart name and version for postgres. */}}
{{- define "postgres.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end }}
