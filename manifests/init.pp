# == Class: go_carbon
# == Description: Installs the go-carbon package and the shared configuration files
#
class go_carbon(
  $ensure                   = 'present',
  $package_name             = $go_carbon::params::package_name,
  $version                  = $go_carbon::params::version,
  $executable               = $go_carbon::params::executable,
  $config_dir               = $go_carbon::params::config_dir,
  $user                     = $go_carbon::params::user,
  $group                    = $go_carbon::params::group,
  $storage_aggregations     = $go_carbon::params::storage_aggregations,
  $storage_schemas          = $go_carbon::params::storage_schemas,
  $download_package         = $go_carbon::params::download_package,
  $shell                    = $go_carbon::params::shell,
) inherits go_carbon::params {

  validate_re($::osfamily, '^(RedHat|Debian)', 'This module is only supported on RHEL/CentOS 6/7 or Ubuntu 16.04')
  validate_re($::operatingsystemmajrelease, '^[67]|16.04$', 'This module is only supported on RHEL/CentOS 6/7 or Ubuntu 16.04')

  validate_string($package_name)
  validate_string($version)
  validate_absolute_path($executable)
  validate_absolute_path($config_dir)
  validate_string($user)
  validate_string($group)
  validate_array($storage_aggregations)
  validate_array($storage_schemas)

  include go_carbon::install
  include go_carbon::config

  Class['go_carbon::install'] ->
  Class['go_carbon::config']
}
