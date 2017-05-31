# == Class: opendkim
#
# === Examples
#
#  class { 'opendkim':}
#
# === Authors
#
# Vladimir Bykanov <vladimir@bykanov.ru>
# Michael Meschansky https://github.com/meschansky
#
# === Copyright
#
# Copyright 2015 Vladimir Bykanov
#
class opendkim (
  $autorestart          = 'Yes',
  $autorestart_rate     = '10/1h',
  $log_why              = 'Yes',
  $syslog               = 'Yes',
  $syslog_success       = 'Yes',
  $mode                 = 's',
  $canonicalization     = 'relaxed/simple',
  $external_ignore_list = 'refile:/etc/opendkim/TrustedHosts',
  $internal_hosts       = 'refile:/etc/opendkim/TrustedHosts',
  $keytable             = 'refile:/etc/opendkim/KeyTable',
  $signing_table        = 'refile:/etc/opendkim/SigningTable',
  $signature_algorithm  = 'rsa-sha256',
  $socket               = 'inet:8891@localhost',
  $pidfile              = '/var/run/opendkim/opendkim.pid',
  $umask                = '022',
  $userid               = 'opendkim:opendkim',
  $temporary_directory  = '/var/tmp',
  $default_conf         = '/etc/default/opendkim',
  $package_name         = 'opendkim',
  $service_name         = 'opendkim',
  $pathconf             = '/etc/opendkim',
  $owner                = 'opendkim',
  $group                = 'opendkim',
  $replace_headers      = '/etc/opendkim/ReplaceHeaders',
  $replace_rules        = '/etc/opendkim/ReplaceRules',
  $nameservers          = undef,) {
  package { $package_name: ensure => latest, }

  case $::operatingsystem {
    /^(Debian|Ubuntu)$/ : {
      package { 'opendkim-tools': ensure => latest, }

      file {'/var/run/opendkim/':
          ensure  => directory,
          owner   => $owner,
          group   => $group,
          mode    => '0755',
          require => Package[$package_name],
          notify  => Service[$package_name],
      }

      # Debian/Ubuntu doesn't ship this directory in its package
      file { $pathconf:
        ensure  => directory,
        owner   => 'root',
        group   => $group,
        mode    => '0755',
        require => Package[$package_name],
        notify  => Service[$package_name],
      }

      file { "${pathconf}/keys":
        ensure  => directory,
        owner   => $owner,
        group   => $group,
        mode    => '0750',
        require => Package[$package_name],
        notify  => Service[$package_name],
      }

      file { "${pathconf}/KeyTable":
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => '0640',
        require => Package[$package_name],
        notify  => Service[$package_name],
      }

      file { "${pathconf}/SigningTable":
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => '0640',
        require => Package[$package_name],
        notify  => Service[$package_name],
      }

      file { "${pathconf}/TrustedHosts":
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => '0644',
        require => Package[$package_name],
        notify  => Service[$package_name],
      }

      $usergroup = split($userid, ':')
      # init script included into Debian/Ubuntu package respects user paramter from /etc/default/ only
      augeas { $default_conf:
          lens    => 'Shellvars.lns',
          incl    => $default_conf,
          context => "/files/${default_conf}",
          changes => [
            "set USER ${usergroup[0]}",
          ],
          require => Package[$package_name],
          notify  => Service[$package_name],
      }
    }
    default             : {
    }
  }

  file { '/etc/opendkim.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('opendkim/opendkim.conf'),
    notify  => Service[$service_name],
    require => Package[$package_name],
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => Package[$package_name],
  }
}

