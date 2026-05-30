# Changelog

All notable changes to this project will be documented in this file.

## Release 0.3.0

**Features**

* Collect **per-release** download counts (`/v3/releases`) instead of a single
  module total, with pagination handled correctly.
* Record a richer CSV: `date,module,version,downloads,delta`, where `delta` is
  the day-over-day change per version.
* Idempotent collection: re-running on the same day no longer appends duplicate
  rows.
* Parse the API with `jq` (managed by the class) instead of `grep`/`awk`, and
  slim the API payload via `exclude_fields`.

## Release 0.2.0

**Features**

* Schedule the scrape via an `/etc/cron.d` job, toggled by the `$plot` parameter.
* Write per-module CSVs into the configurable `$scrape_dir`.

**Bugfixes**

* Render the template with `epp()` instead of `template()` (the file is EPP, so
  catalog compilation previously failed).
* Iterate the `$modules` array correctly in the generated bash loop.
* Query the Forge `/v3/modules/<module>` endpoint for the aggregate download
  count, avoiding pagination undercounts from the previous `/v3/releases` sum.
* Drop the hardcoded `/home/centos` CSV path.

**Maintenance**

* Raise the supported Puppet range to `>= 7.0.0 < 9.0.0` and refresh
  `operatingsystem_support` to current OS releases.
* Modernise the PDK scaffold (`pdk update`).

## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**
