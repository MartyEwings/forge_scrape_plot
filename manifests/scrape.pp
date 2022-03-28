# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include forge_scrape_plot::scrape
class forge_scrape_plot::scrape (

  Array[String] $modules = ['puppetlabs-support_tasks', 'puppetlabs-puppet_operational_dashboards', 'puppetlabs-pe_status_check', 'puppetlabs-influxdb'],
  String $scrape_dir  = '/var/log/forge_scrape/',
  Boolean $plot = false,
) {
  file { '/var/forge_plot.sh':
    ensure  => file,
    content => template('forge_scrape_plot/forge_scrape.epp'),
  }
}
