#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: ceilometer::wsgi::apache
#
# Class to serve Ceilometer API with apache mod_wsgi in place of ceilometer-api service.
#
# Serving Ceilometer API from apache is the recommended way to go for production
# because of limited performance for concurrent accesses when running eventlet.
#
# When using this class you should disable your ceilometer-api service.
#
# === Parameters:
#
# [*servername*]
#   (Optional) The servername for the virtualhost.
#   Defaults to $::fqdn.
#
# [*port*]
#   (Optional) The port.
#   Defaults to 8777.
#
# [*bind_host*]
#   (Optional) The host/ip address Apache will listen on.
#   Defaults to undef (listen on all ip addresses).
#
# [*path*]
#   (Optional) The prefix for the endpoint.
#   Defaults to '/'.
#
# [*ssl*]
#   (Optional) Use ssl ? (boolean)
#   Defaults to true.
#
# [*workers*]
#   (Optional) Number of WSGI workers to spawn.
#   Defaults to 1.
#
# [*priority*]
#   (Optional) The priority for the vhost.
#   Defaults to '10'.
#
# [*threads*]
#   (Optional) The number of threads for the vhost.
#   Defaults to $::os_workers.
#
# [*wsgi_process_display_name*]
#   (optional) Name of the WSGI process display-name.
#   Defaults to undef
#
# [*ssl_cert*]
# [*ssl_key*]
# [*ssl_chain*]
# [*ssl_ca*]
# [*ssl_crl_path*]
# [*ssl_crl*]
# [*ssl_certs_dir*]
#   (Optional) apache::vhost ssl parameters.
#   Default to apache::vhost 'ssl_*' defaults.
#
# [*access_log_file*]
#   The log file name for the virtualhost.
#   Optional. Defaults to false.
#
# [*access_log_format*]
#   The log format for the virtualhost.
#   Optional. Defaults to false.
#
# [*error_log_file*]
#   The error log file name for the virtualhost.
#   Optional. Defaults to undef.
#
# [*custom_wsgi_process_options*]
#   (optional) gives you the oportunity to add custom process options or to
#   overwrite the default options for the WSGI main process.
#   eg. to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# === Dependencies:
#
#   requires Class['apache'] & Class['ceilometer']
#
# === Examples:
#
#   include apache
#
#   class { 'ceilometer::wsgi::apache': }
#
class ceilometer::wsgi::apache (
  $servername                  = $::fqdn,
  $port                        = 8777,
  $bind_host                   = undef,
  $path                        = '/',
  $ssl                         = true,
  $workers                     = 1,
  $ssl_cert                    = undef,
  $ssl_key                     = undef,
  $ssl_chain                   = undef,
  $ssl_ca                      = undef,
  $ssl_crl_path                = undef,
  $ssl_crl                     = undef,
  $ssl_certs_dir               = undef,
  $wsgi_process_display_name   = undef,
  $threads                     = $::os_workers,
  $priority                    = '10',
  $access_log_file             = false,
  $access_log_format           = false,
  $error_log_file              = undef,
  $custom_wsgi_process_options = {},
) {

  include ::ceilometer::deps
  include ::ceilometer::params
  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  # NOTE(aschultz): needed because the packaging may introduce some apache
  # configuration files that apache may remove. See LP#1657309
  Anchor['ceilometer::install::end'] -> Class['apache']

  ::openstacklib::wsgi::apache { 'ceilometer_wsgi':
    bind_host                   => $bind_host,
    bind_port                   => $port,
    group                       => 'ceilometer',
    path                        => $path,
    priority                    => $priority,
    servername                  => $servername,
    ssl                         => $ssl,
    ssl_ca                      => $ssl_ca,
    ssl_cert                    => $ssl_cert,
    ssl_certs_dir               => $ssl_certs_dir,
    ssl_chain                   => $ssl_chain,
    ssl_crl                     => $ssl_crl,
    ssl_crl_path                => $ssl_crl_path,
    ssl_key                     => $ssl_key,
    threads                     => $threads,
    user                        => 'ceilometer',
    workers                     => $workers,
    wsgi_daemon_process         => 'ceilometer',
    wsgi_process_display_name   => $wsgi_process_display_name,
    wsgi_process_group          => 'ceilometer',
    wsgi_script_dir             => $::ceilometer::params::ceilometer_wsgi_script_path,
    wsgi_script_file            => 'app',
    wsgi_script_source          => $::ceilometer::params::ceilometer_wsgi_script_source,
    custom_wsgi_process_options => $custom_wsgi_process_options,
    access_log_file             => $access_log_file,
    access_log_format           => $access_log_format,
    error_log_file              => $error_log_file,
  }
}
