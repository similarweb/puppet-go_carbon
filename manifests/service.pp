# == Resource: go_carbon::service
# == Description: Installs an upstart / systemd service definition.
define go_carbon::service(
  $service_name = $title,
  $service_ensure = 'running',
  $service_enable = true)
{
  case $::operatingsystemmajrelease {
    '6': {
      # Put the upstart config file
      file { "/etc/init/go-carbon_${service_name}.conf":
        ensure  => $go_carbon::ensure,
        content => template("${module_name}/upstart.go-carbon.conf.erb")
      }

      # Instantiate the go-carbon service
      service {
        "go-carbon_${service_name}":
          ensure     => $service_ensure,
          hasrestart => false,
          stop       => "/sbin/initctl stop go-carbon_${service_name}",
          start      => "/sbin/initctl start go-carbon_${service_name}",
          status     => "/sbin/initctl status go-carbon_${service_name} | grep -q -- '/running'",
          subscribe  => [File["/etc/init/go-carbon_${service_name}.conf"],
                            File["${go_carbon::config_dir}/${service_name}.conf"]]
      }
    }

    '7', '16.04': {
      file { "${::go_carbon::systemd_service_folder}/go-carbon_${service_name}.service":
        ensure  => $go_carbon::ensure,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/systemd.go-carbon.conf.erb")
      } ~>
      Exec['systemctl-daemon-reload']
      service { "go-carbon_${service_name}":
        ensure    => $service_ensure,
        enable    => $service_enable,
        provider  => systemd,
        subscribe =>
        [
          File["${go_carbon::systemd_service_folder}/go-carbon_${service_name}.service"],
          File["${go_carbon::config_dir}/${service_name}.conf"]
        ]
      }
    }

    default: {
      fail("Unable to install a go-carbon service on OS version ${::operatingsystemmajrelease}.")
    }
  }
}
