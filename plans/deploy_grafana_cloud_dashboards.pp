# Load Puppet Operational Dashboards into Grafana Cloud
plan puppet_operational_dashboards::deploy_grafana_cloud_dashboards (
  String $grafana_url,
  String $token_file,
  Boolean $include_pe_metrics = false,
) {
  $dashboards = [
    'Puppetserver',
    'Puppetdb',
    'Postgresql',
  ]

  if $include_pe_metrics {
    $pe_dashboards = ['Filesync', 'Orchestrator']
  } else {
    $pe_dashboards = []
  }

  if file::exists($token_file) {
    $token = file::read($token_file).chomp
  } else {
    $token = file::read("puppet_operational_dashboards/${token_file}").chomp
  }

  apply_prep('localhost')

  apply('localhost') {
    ($dashboards + $pe_dashboards).each |$board| {
      grafana_dashboard { $board:
        ensure        => present,
        grafana_token => $token,
        grafana_url   => $grafana_url,
        content       => file("puppet_operational_dashboards/promql/${board}_performance.json"),
      }
    }
  }
}
