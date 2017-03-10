# == Resource: go_carbon::instance
# == Description: Defines a go-carbon service instance, including service management
#
define go_carbon::instance(
  $service_name                    = $title,
  $ensure                          = 'present',
  $log_file                        = $go_carbon::params::log_file,
  $log_level                       = $go_carbon::params::log_level,
  $go_maxprocs                     = $go_carbon::params::go_maxprocs,
  $internal_graph_prefix           = $go_carbon::params::internal_graph_prefix,
  $internal_metrics_interval       = $go_carbon::params::internal_metrics_interval,
  $internal_metrics_endpoint       = $go_carbon::params::internal_metrics_endpoint,
  $max_cpu                         = $go_carbon::params::max_cpu,
  $whisper_data_dir                = $go_carbon::params::whisper_data_dir,
  $whisper_schemas_file            = $go_carbon::params::whisper_schemas_file,
  $whisper_aggregation_file        = $go_carbon::params::whisper_aggregation_file,
  $whisper_workers                 = $go_carbon::params::whisper_workers,
  $whisper_max_updates_per_second  = $go_carbon::params::whisper_max_updates_per_second,
  $whisper_sparse_create	   = $go_carbon::params::whisper_sparse_create,
  $whisper_enabled                 = $go_carbon::params::whisper_enabled,
  $cache_max_size                  = $go_carbon::params::cache_max_size,
  $cache_input_buffer              = $go_carbon::params::cache_input_buffer,
  $cache_write_strategy            = $go_carbon::params::cache_write_strategy,
  $udp_listen                      = $go_carbon::params::udp_listen,
  $udp_log_incomplete              = $go_carbon::params::udp_log_incomplete,
  $udp_enabled                     = $go_carbon::params::udp_enabled,
  $tcp_listen                      = $go_carbon::params::tcp_listen,
  $tcp_enabled                     = $go_carbon::params::tcp_enabled,
  $pickle_listen                   = $go_carbon::params::pickle_listen,
  $pickle_max_message_size         = $go_carbon::params::pickle_max_message_size,
  $pickle_enabled                  = $go_carbon::params::pickle_enabled,
  $carbonlink_listen               = $go_carbon::params::carbonlink_listen,
  $carbonlink_enabled              = $go_carbon::params::carbonlink_enabled,
  $carbonlink_read_timeout         = $go_carbon::params::carbonlink_read_timeout,
  $carbonlink_query_timeout        = $go_carbon::params::carbonlink_query_timeout,
  $carbonserver_listen             = $go_carbon::params::carbonserver_listen,
  $carbonserver_enabled            = $go_carbon::params::carbonserver_enabled,
  $carbonserver_buckets            = $go_carbon::params::carbonserver_buckets,
  $carbonserver_max_globs          = $go_carbon::params::carbonserver_max_globs,
  $carbonserver_metrics_as_counters = $go_carbon::params::carbonserver_metrics_as_counters,
  $carbonserver_read_timeout       = $go_carbon::params::carbonserver_read_timeout,
  $carbonserver_write_timeout      = $go_carbon::params::carbonserver_write_timeout,
  $carbonserver_scan_frequency     = $go_carbon::params::carbonserver_scan_frequency,
  $dump_enabled                    = $go_carbon::params::dump_enabled,
  $dump_path                       = $go_carbon::params::dump_path,
  $dump_restore_per_second         = $go_carbon::params::dump_restore_per_second,
  $pprof_listen                    = $go_carbon::params::pprof_listen,
  $pprof_enabled                   = $go_carbon::params::pprof_enabled,
)
{
  include go_carbon

  validate_absolute_path($log_file)
  validate_re($log_level, [ '^debug', '^info', '^warn', '^warning', '^error' ],
    "Invalid log level ${log_level}, Valid values: 'debug', 'info', 'warn', 'warning', 'error'")
  validate_string($internal_graph_prefix)
  validate_string($internal_metrics_interval)

  if $internal_metrics_endpoint {
    validate_string($internal_metrics_endpoint)
  }

  validate_integer($max_cpu)
  validate_absolute_path($whisper_data_dir)
  validate_integer($whisper_workers)
  validate_integer($whisper_max_updates_per_second)
  validate_bool($whisper_sparse_create)
  validate_bool($whisper_enabled)
  validate_integer($cache_max_size)
  validate_integer($cache_input_buffer)
  validate_string($cache_write_strategy)
  validate_integer($go_maxprocs)

  validate_re($udp_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid udp listen ${udp_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($udp_log_incomplete)
  validate_bool($udp_enabled)
  
  validate_re($tcp_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid tcp listen ${tcp_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($tcp_enabled)
  
  validate_re($pickle_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid pickle listen ${pickle_listen}. Must be {ip}:{port} or just :{port}")

  validate_integer($pickle_max_message_size)
  validate_bool($pickle_enabled)
  
  validate_re($carbonlink_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid carbonlink listen ${carbonlink_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($carbonlink_enabled)
  validate_string($carbonlink_read_timeout)
  validate_string($carbonlink_query_timeout)
  
  validate_re($pprof_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid pprof listen ${pprof_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($pprof_enabled)
  validate_absolute_path($whisper_schemas_file)
  validate_absolute_path($whisper_aggregation_file)

  validate_string($carbonserver_listen)
  validate_bool($carbonserver_enabled)
  validate_integer($carbonserver_buckets)
  validate_integer($carbonserver_max_globs)
  validate_bool($carbonserver_metrics_as_counters)
  validate_string($carbonserver_read_timeout)
  validate_string($carbonserver_write_timeout)
  validate_string($carbonserver_scan_frequency)

  validate_bool($dump_enabled)
  if $dump_path {
    validate_string($dump_path)
  }
  validate_integer($dump_restore_per_second)

  # Put the configuration files
  $executable = $go_carbon::executable
  $config_dir = $go_carbon::config_dir
  $user       = $go_carbon::user

  file {
    "${go_carbon::config_dir}/${service_name}.conf":
      ensure  => $ensure,
      content => template("${module_name}/go-carbon.conf.erb")
  }

  Class[$module_name] ->
  File["${go_carbon::config_dir}/${service_name}.conf"]
}
