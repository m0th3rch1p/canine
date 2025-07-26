{{/*
Expand the name of the chart.
*/}}
{{- define "canine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "canine.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "canine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "canine.labels" -}}
helm.sh/chart: {{ include "canine.chart" . }}
{{ include "canine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "canine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "canine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "canine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "canine.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create PostgreSQL host
*/}}
{{- define "canine.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "canine.fullname" .) }}
{{- else }}
{{- required "A valid .Values.rails.databaseUrl must be provided when postgresql.enabled is false" .Values.rails.databaseUrl }}
{{- end }}
{{- end }}

{{/*
Create PostgreSQL port
*/}}
{{- define "canine.postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
5432
{{- else }}
5432
{{- end }}
{{- end }}

{{/*
Create Redis host
*/}}
{{- define "canine.redis.host" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "canine.fullname" .) }}
{{- else }}
{{- required "A valid .Values.rails.redisUrl must be provided when redis.enabled is false" .Values.rails.redisUrl }}
{{- end }}
{{- end }}

{{/*
Create Redis port
*/}}
{{- define "canine.redis.port" -}}
{{- if .Values.redis.enabled }}
6379
{{- else }}
6379
{{- end }}
{{- end }}

{{/*
Create database URL
*/}}
{{- define "canine.databaseUrl" -}}
{{- if .Values.rails.databaseUrl }}
{{- .Values.rails.databaseUrl }}
{{- else if .Values.postgresql.enabled }}
{{- printf "postgresql://%s:%s@%s:5432/%s" .Values.postgresql.auth.username .Values.postgresql.auth.password (include "canine.postgresql.host" .) .Values.postgresql.auth.database }}
{{- else }}
{{- required "Either postgresql.enabled must be true or rails.databaseUrl must be provided" .Values.rails.databaseUrl }}
{{- end }}
{{- end }}

{{/*
Create Redis URL
*/}}
{{- define "canine.redisUrl" -}}
{{- if .Values.rails.redisUrl }}
{{- .Values.rails.redisUrl }}
{{- else if .Values.redis.enabled }}
{{- if .Values.redis.auth.enabled }}
{{- printf "redis://:%s@%s:6379/0" .Values.redis.auth.password (include "canine.redis.host" .) }}
{{- else }}
{{- printf "redis://%s:6379/0" (include "canine.redis.host" .) }}
{{- end }}
{{- else }}
{{- required "Either redis.enabled must be true or rails.redisUrl must be provided" .Values.rails.redisUrl }}
{{- end }}
{{- end }}