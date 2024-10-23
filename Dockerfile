FROM quay.io/curl/curl-base:8.10.1

RUN apk add jq
ADD . .

ENTRYPOINT [ "sh" , "-c" "./alertmanager_provisioner.sh" ]
