# ex: si ts=4 sw=4 et

define shorewall::host (
    $zone        = '',
    $interface,
    $addresses,
    $exclusion   = '',
    $options     = [ '-' ],
    Shorewall::TypeInetProtocol $protocol,
) {
  if defined(Class['shorewall']) {
    include shorewall

    $zone_name = $zone ? {
      '' => $name,
      default => $zone,
    }

    if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
      concat::fragment { "shorewall-host-ipv4-${name}":
        target  => '/etc/shorewall/hosts',
        content => template('shorewall/host.erb'),
      }
    }
    if (($protocol == 'ipv6' or $protocol == 'all') and $::shorewall::ipv6) {
      concat::fragment { "shorewall-host-ipv6-${name}":
        target  => '/etc/shorewall6/hosts',
        content => template('shorewall/host.erb'),
      }
    }
  } else {
    fail('Class shorewall must be declared before this resource can be used')
  }
}
