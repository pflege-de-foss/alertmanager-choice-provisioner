FROM quay.io/curl/curl-base:8.10.1
LABEL org.opencontainers.image.description "Simle provisioner to provision external alertmanagers in Grafana"

RUN apk add jq
ADD . .

ENTRYPOINT [ "sh", "-c", "./alertmanager_provisioner.sh" ]
