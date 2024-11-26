# Grafana Alertmanager choice provisioner

This container configures the alertmanager choice, which Grafana will use to dispatch alerts.

The following choices are valid:

* `internal`: Only uses the internal alertmanager provided by Grafana.
* `all`: Sends alerts to the internal and all external alertmanager(s).
* `external`: Only sends alerts to the external alertmanager(s).

When the configuration is successfully validated or updated, the provisioner will recheck every 5 minutes.

If an error occurs updating the configuration it retries after 10 seconds.

## Configuration

The provisioner is configured by environment variables.

| variable          | value                                               | default                                |
| ----------------- | --------------------------------------------------- | -------------------------------------- |
| `choice`          | one of `internal`, `all`, `external`                | -                                      |
| `url`             | base url for configuring alerts admin configuration | `http://localhost:3000/api/vi/ngalert` |
| `username`        | Admin username                                      | `admin`                                |
| `password`        | Admin password                                      | `prom-operator`                        |
| `update_interval` | Interval for checking settings in seconds           | `300`                                  |
| `retry_interval`  | Interval to retry in case of errors in seconds      | `10`                                   |

## Safeguards

* the configured choice is checked on startup. The provisioner will fail to start up on invalid values.
* if the number of configured external alertmanagers is less than one, the provisioner reverts to `internal`.

## Usage

The provisioner is most useful when used in conjunction with the grafana Helm chart od the kube-prometheus-stack Helm chart
which includes the grafana Helm chart.

```yaml
  extraContainers: |
    - name: alertconfig
      image: ghcr.io/pflege-de-foss/alertmanager-choice-provisioner:0.1.0
      env:
        - name: choice
          value: all
        - name: username
          valueFrom:
            secretKeyRef:
              key: admin-user
              name: grafana-credentials
        - name: password
          valueFrom:
            secretKeyRef:
              key: admin-password
              name: grafana-credentials
  ```

## Sources

Inspired by: https://community.grafana.com/t/how-to-send-alerts-to-external-alertmanager/76198/7
