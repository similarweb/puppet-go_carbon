# go_carbon

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with go_carbon](#setup)
    * [Limitations - OS compatibility, etc.](#limitations)
    * [What go_carbon affects](#what-go_carbon-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with go_carbon](#beginning-with-go_carbon)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Multi instance deployment - important notes](#multi-instance)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages [go_carbon][1] by [lomik][2].

## Module Description

This module has been tested against go_carbon versions: 0.5, 0.7

## Setup

### Limitations
You must provide your own RPM - these can be built from the project sources by issuing
```
make rpm
```
More info [here][2].

The module has been tested on CentOS 6

### The module manages the following

* The go_carbon package.
* upstart / systemd services configuration file.
* Multiple go_carbon instances supported (i.e. for JBOD sharding)
* Aggregations / Schemas

### Important Note
Please refer to go_carbon [installation][2] before using this module.

### Setup Requirements

go_carbon module depends on the following puppet modules:

* puppetlabs-stdlib >= 1.0.0
* camptocamp-systemd >= 0.2.2 (CentOS 7 and up)

### Beginning with go_carbon

Install this module via any of these approaches:

* [librarian-puppet][3]
* `puppet module install similarweb-go_carbon`

## Usage

## Multi Instance 
This module supports multiple instances of go_carbon managed on one machine. 
You can define completely different configurations per managed instance, but the schemas aggregation and storage definition are _shared_ across.

### Main class

#### Install go_carbon 0.7 by means of a yum repo

```puppet
class { 'go_carbon':
  package_name => 'go_carbon',
  version => '0.7-1.el6',
}
```

#### Start a go_carbon instance with default configuration

```puppet
class { 'go_carbon': } ->
go_carbon::instance { 'default': }
```

#### Support for multiple instances
```puppet
go_carbon::instance { 'instance_1': 
  tcp_listen => ':2003',
  udp_enabled => false,
  whisper_data_dir => '/data1'  
}

go_carbon::instance { 'instance_2': 
  tcp_listen => ':2103',
  udp_enabled => false,
  whisper_data_dir => '/data2'
}
```

## Hiera Support

* Example: Defining storage schemas in hiera

```yaml
go_carbon::storage_schemas:
  - carbon:
      pattern: '^carbon\.'
      retentions: '1m:30d'
  - collectd:
      pattern: '^collectd.*'
      retentions: '20s:1d,1m:14d,10m:90d'
  - default_1min_for_7day:
      pattern: '.*'
      retentions: '1m:7d'
```

* Example: Defining 4 go_carbon instances with hiera

```yaml
roles::graphite::go_carbon_instances:
    data1:
        tcp_listen: 0.0.0.0:2103
        udp_enabled: false
        pickle_listen: 0.0.0.0:2104
        carbonlink_listen: 127.0.0.1:7102
        whisper_data_dir: /data1/whisper
        log_file: /var/log/go_carbon/data1.log
        whisper_max_updates_per_second: 4000
    data2:
        tcp_listen: 0.0.0.0:2203
        udp_enabled: false
        pickle_listen: 0.0.0.0:2204
        carbonlink_listen: 127.0.0.1:7202
        whisper_data_dir: /data2/whisper
        log_file: /var/log/go_carbon/data2.log
        whisper_max_updates_per_second: 4000
    data3:
        tcp_listen: 0.0.0.0:2303
        pickle_listen: 0.0.0.0:2304
        udp_enabled: false
        carbonlink_listen: 127.0.0.1:7302
        whisper_data_dir: /data3/whisper
        log_file: /var/log/go_carbon/data3.log        
        whisper_max_updates_per_second: 4000
    data4:
        tcp_listen: 0.0.0.0:2403
        pickle_listen: 0.0.0.0:2404
        udp_enabled: false
        carbonlink_listen: 127.0.0.1:7402
        log_file: /var/log/go_carbon/data4.log        
        whisper_data_dir: /data4/whisper
        whisper_max_updates_per_second: 4000
```

Then in the manifest:
```puppet
    create_resources(go_carbon::instance, hiera('roles::graphite::go_carbon_instances'), {})
```


## Reference

### Classes

#### Public classes

* `go_carbon` - Installs and configures shared go_carbon configuration.
* `go_carbon::instance` - Configures and launches a go_carbon instance. This is a defined resource and can be used multiple times.

#### Private classes
* `go_carbon::install` - Installs the go_carbon package
* `go_carbon::config` - Configures storage aggregations / schemas
* `go_carbon::service` - Installs the upstart / systemd service


## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `feature/add_component_x`)
3. Commit your changes.
4. Submit a Pull Request using Github


[1]: https://github.com/lomik/go_carbon
[2]: https://github.com/lomik/go_carbon#installation
[3]: https://github.com/rodjek/librarian-puppet
