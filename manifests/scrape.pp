# @summary Scrapes Puppet Forge download counts for a set of modules.
#
# Installs a small shell script that polls the Puppet Forge API for the
# per-release download counts of each configured module and appends one row
# per version to a per-module CSV (date,module,version,downloads,delta). A
# cron job runs the script on a schedule so the CSVs build up a download
# history over time, with a day-over-day delta computed per version.
#
# Requires `jq` (managed by this class) and `curl` (assumed present).
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

  # The collector parses the Forge API JSON with jq. curl is assumed present
  # (it is on every supported platform, and on RHEL the base curl-minimal
  # package satisfies it without conflicting).
  package { 'jq':
    ensure => installed,
  }

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
    require => [File[$script], Package['jq']],
  }
}
