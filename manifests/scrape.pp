# @summary Scrapes Puppet Forge download counts for a set of modules.
#
# Installs a small shell script that polls the Puppet Forge API for the
# total download count of each configured module and appends a timestamped
# row to a per-module CSV. A cron job runs the script on a schedule so the
# CSVs build up a download history over time.
#
# @param modules
#   Forge module slugs (`owner-name`) to track.
# @param scrape_dir
#   Directory the per-module CSV files are written to.
# @param plot
#   When true, installs a /etc/cron.d job that runs the scrape on a schedule.
#   When false, the script is installed but not scheduled.
#
# @example
#   include forge_scrape_plot::scrape
class forge_scrape_plot::scrape (
  Array[String[1]] $modules = [
    'puppetlabs-support_tasks',
    'puppetlabs-puppet_operational_dashboards',
    'puppetlabs-pe_status_check',
    'puppetlabs-influxdb',
  ],
  String[1] $scrape_dir = '/var/log/forge_scrape',
  Boolean $plot = false,
) {
  $script = '/usr/local/bin/forge_plot.sh'
  $cron_ensure = $plot ? { true => 'file', default => 'absent' }

  file { $scrape_dir:
    ensure => directory,
    mode   => '0755',
  }

  file { $script:
    ensure  => file,
    mode    => '0755',
    content => epp('forge_scrape_plot/forge_scrape.epp', {
        'modules'    => $modules,
        'scrape_dir' => $scrape_dir,
    }),
  }

  # Run daily at midnight. Using /etc/cron.d keeps the module dependency-free
  # (the `cron` resource type now lives in the separate cron_core module).
  file { '/etc/cron.d/forge_scrape_plot':
    ensure  => $cron_ensure,
    mode    => '0644',
    content => "# Managed by Puppet (forge_scrape_plot::scrape)\n0 0 * * * root ${script}\n",
    require => File[$script],
  }
}
