# == Class: ceilometer::agent::service_credentials
#
# The ceilometer::agent::service_credentials class helps configure common
# service credentials settings for the agents.
#
# === Parameters:
#
# [*password*]
#   (Required) the keystone password for ceilometer services
#
# [*auth_url*]
#   (Optional) the keystone public endpoint
#   Defaults to 'http://localhost:5000'.
#
# [*region_name*]
#   (Optional) the keystone region of this node
#   Defaults to $::os_service_default.
#
# [*username*]
#   (Optional) the keystone user for ceilometer services
#   Defaults to 'ceilometer'.
#
# [*project_name*]
#   (Optional) the keystone project name for ceilometer services
#   Defaults to 'services'.
#
# [*cafile*]
#   (Optional) Certificate chain for SSL validation.
#   Defaults to $::os_service_default.
#
# [*interface*]
#   (Optional) Type of endpoint in Identity service catalog to use for
#   communication with OpenStack services.
#   Defaults to $::os_service_default.
#
# [*user_domain_name*]
#   (Optional) domain name for auth user.
#   Defaults to 'Default'.
#
# [*project_domain_name*]
#   (Optional) domain name for auth project.
#   Defaults to 'Default'.
#
# [*auth_type*]
#   (Optional) Authentication type to load.
#   Defaults to 'password'.
#
class ceilometer::agent::service_credentials (
  $password,
  $auth_url            = 'http://localhost:5000',
  $region_name         = $::os_service_default,
  $username            = 'ceilometer',
  $project_name        = 'services',
  $cafile              = $::os_service_default,
  $interface           = $::os_service_default,
  $user_domain_name    = 'Default',
  $project_domain_name = 'Default',
  $auth_type           = 'password',
) {

  include ceilometer::deps

  ceilometer_config {
    'service_credentials/auth_url'           : value => $auth_url;
    'service_credentials/region_name'        : value => $region_name;
    'service_credentials/username'           : value => $username;
    'service_credentials/password'           : value => $password, secret => true;
    'service_credentials/project_name'       : value => $project_name;
    'service_credentials/cafile'             : value => $cafile;
    'service_credentials/interface'          : value => $interface;
    'service_credentials/user_domain_name'   : value => $user_domain_name;
    'service_credentials/project_domain_name': value => $project_domain_name;
    'service_credentials/auth_type'          : value => $auth_type;
  }
}
