{
  local thanos = self,
  sidecar+:: {
    selector: error 'must provide selector for Thanos Sidecar alerts',
  },
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'thanos-sidecar.rules',
        rules: [
          {
            alert: 'ThanosSidecarPrometheusDown',
            annotations: {
              message: 'Thanos Sidecar {{$labels.job}} cannot connect to Prometheus.',
            },
            expr: |||
              max(thanos_sidecar_prometheus_up{%(selector)s}) by (job) == 0
            ||| % thanos.sidecar,
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
          {
            alert: 'ThanosSidecarUnhealthy',
            annotations: {
              message: 'Thanos Sidecar {{$labels.job}} is unhealthy for {{ $value }} seconds.',
            },
            expr: |||
              time() - max(thanos_sidecar_last_heartbeat_success_time_seconds{%(selector)s}) by (job) >= 300
            ||| % thanos.sidecar,
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  },
}
