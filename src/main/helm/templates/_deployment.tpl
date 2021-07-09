{{- define "deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: devx-helloworld-springboot-x9iea
    backstage.io/kubernetes-id: devx-helloworld-springboot-x9iea
    slot: {{ .slot }}
  name: devx-helloworld-springboot-x9iea-{{ .slot }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: devx-helloworld-springboot-x9iea
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: devx-helloworld-springboot-x9iea
        backstage.io/kubernetes-id: devx-helloworld-springboot-x9iea
        slot: {{ .slot }}
    spec:
      containers:
      - image: {{ .Values.config.image.name }}:{{ .Values.config.image.tag }}
        imagePullPolicy: IfNotPresent
        name: devx-helloworld-springboot-x9iea
        resources: {}
        ports:
          - containerPort: 8080 
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          periodSeconds: 5
status: {}
{{- end }}
