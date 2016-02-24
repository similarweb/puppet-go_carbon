# == Class: go_carbon::install
# == Description: Creates the user/group, installs the package and creates the config dir.
class go_carbon::install inherits go_carbon {
  group { $go_carbon::group:
    ensure => $go_carbon::ensure,
  }

  user { $go_carbon::user:
    ensure => $go_carbon::ensure,
    gid    => $go_carbon::group,
    shell  => '/sbin/nologin'
  }

  package { $go_carbon::package_name:
    ensure => $go_carbon::version
  }

  # Create the go-carbon conf dir
  file { $go_carbon::config_dir:
    ensure => $go_carbon::ensure ? { 'present' =>  'directory', default => 'absent' }
  }
}