# == Class: go_carbon::install
# == Description: Creates the user/group, installs the package and creates the config dir.
class go_carbon::install inherits go_carbon {
  group { $go_carbon::group:
    ensure => $go_carbon::ensure,
  }

  user { $go_carbon::user:
    ensure => $go_carbon::ensure,
    gid    => $go_carbon::group,
    shell  => $go_carbon::shell,
  }

  case $::osfamily {
    'Debian': {
      if $go_carbon::download_package {
        exec { 'download package from release':
          command => "/usr/bin/curl -s -o /tmp/go-carbon_${go_carbon::version}_amd64.deb ${go_carbon::download_deb_url}",
          cwd     => '/tmp',
          unless  => "/usr/bin/apt show go-carbon=${go_carbon::version}",
        } ~>

        package { $go_carbon::package_name:
          provider => dpkg,
          source   => "/tmp/go-carbon_${go_carbon::version}_amd64.deb",
        }
      } else {
        package { $go_carbon::package_name:
          ensure => $go_carbon::version
        }
      }
    }

    'RedHat': {
      package { $go_carbon::package_name:
        ensure => $go_carbon::version
      }
    }

    default: {
      fail("Unable to install a go-carbon service on OS version ${::operatingsystemmajrelease}.")
    }
  }

  # Create the go-carbon conf dir
  file { $go_carbon::config_dir:
    ensure => $go_carbon::ensure ? { 'present' =>  'directory', default => 'absent' }
  }
}
