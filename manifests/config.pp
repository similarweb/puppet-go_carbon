# == Class: go_carbon::config
# == Description: Creates the log directory and 
#                 writes the schemas and aggregations file
#
class go_carbon::config inherits go_carbon
{
  $log_dir = dirname($go_carbon::log_file)

  file {
    $log_dir:
      ensure => directory,
      owner => $go_carbon::user,
      group => $go_carbon::group;

    $go_carbon::whisper_schemas_file:
      content => template("${module_name}/storage-schemas.conf.erb");

    $go_carbon::whisper_aggregation_file:
      content => template("${module_name}/storage-aggregation.conf.erb")
  }
}