# vim: set tw=2 sw=2 et

define shorewall::policy (
  String $source,
  String $dest,
  String $action,
  String $order     = '50',
  String $log_level = '-',
  Shorewall::TypeInetProtocol $protocol = 'all',
) {
  if defined(Class['shorewall']) {
    include shorewall

    validate_re($order, ['^\d+$'], "Valid values for $order must be an integer.")

    if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
      concat::fragment { "policy-ipv4-${action}-${source}-to-${dest}":
        order   => $order,
        target  => '/etc/shorewall/policy',
        content => "${source} ${dest} ${action} ${log_level}\n",
      }
    }

    if (($protocol == 'ipv6' or $protocol == 'all') and $::shorewall::ipv6) {
      concat::fragment { "policy-ipv6-${action}-${source}-to-${dest}":
        order   => $order,
        target  => '/etc/shorewall6/policy',
        content => "${source} ${dest} ${action} ${log_level}\n",
      }
    }
  } else {
    fail('Class shorewall must be declared before this resource can be used')
  }
}
