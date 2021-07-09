{{- define "service" }}
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: devx-helloworld-springboot-x9iea
    backstage.io/kubernetes-id: devx-helloworld-springboot-x9iea
    slot: {{ .slot }}
  name: devx-helloworld-springboot-x9iea-{{ .slot }}
spec:
  ports:
  - name: 8080-8080
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    slot: {{ .slot }}
{{- end }}
