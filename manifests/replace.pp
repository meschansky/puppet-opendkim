define opendkim::replace (
  # replace_rules_domain should NOT be defined as the title of a resource body
  # if it's an array (i.e. if you have multiple domains to rewrite)
  $replace_rules_domain     = $name,
  $replace_headers_array    = ['from'],
  $replace_headers_template = 'opendkim/ReplaceHeaders',
  $replace_rules_array      = [],
  $replace_rules_template   = 'opendkim/ReplaceRules',
  # if FEATURE(`masquerade_entire_domain') enabled in sendmail
  $masq_entire_domain       = true,) {
  if ( is_array($replace_rules_array) ) and ( size($replace_rules_array) > 0 ) {
    file { $opendkim::replace_rules:
      ensure  => file,
      owner   => $opendkim::owner,
      group   => $opendkim::group,
      mode    => '0640',
      content => template($replace_rules_template),
      notify  => Service[$opendkim::service_name],
      require => Package[$opendkim::package_name],
    }

    file { $opendkim::replace_headers:
      ensure  => file,
      owner   => $opendkim::owner,
      group   => $opendkim::group,
      mode    => '0640',
      content => template($replace_headers_template),
      notify  => Service[$opendkim::service_name],
      require => Package[$opendkim::package_name],
    }
  }
}
