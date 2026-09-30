{{/*
Name of the Barman Cloud ObjectStore resource (plugin method).
*/}}
{{- define "cnpg-cluster.backup.objectStoreName" -}}
{{- .Values.backup.objectStoreName | default (printf "%s-backup" .Values.cluster.name) -}}
{{- end -}}

{{/*
Name of the Secret with S3 credentials.
*/}}
{{- define "cnpg-cluster.backup.s3SecretName" -}}
{{- .Values.backup.s3Credentials.existingSecret | default (printf "%s-backup-s3" .Values.cluster.name) -}}
{{- end -}}

{{/*
Barman object store configuration.
Shared between ObjectStore.spec.configuration (plugin)
and Cluster.spec.backup.barmanObjectStore (in-tree, deprecated).
*/}}
{{- define "cnpg-cluster.backup.barmanConfiguration" -}}
{{- $b := .Values.backup -}}
{{- $secretName := include "cnpg-cluster.backup.s3SecretName" . -}}
destinationPath: {{ required "backup.destinationPath is required when backup.enabled=true" $b.destinationPath | quote }}
{{- if $b.endpointURL }}
endpointURL: {{ $b.endpointURL | quote }}
{{- end }}
{{- with $b.endpointCA }}
endpointCA:
  {{- toYaml . | nindent 2 }}
{{- end }}
s3Credentials:
  accessKeyId:
    name: {{ $secretName }}
    key: ACCESS_KEY_ID
  secretAccessKey:
    name: {{ $secretName }}
    key: ACCESS_SECRET_KEY
  {{- if $b.s3Credentials.properties.region }}
  region:
    name: {{ $secretName }}
    key: ACCESS_REGION
  {{- end }}
{{- with $b.wal }}
wal:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $b.data }}
data:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
