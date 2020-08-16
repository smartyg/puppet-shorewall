# ex: si ts=4 sw=4 et

define shorewall::interface (
    Shorewall::TypeInetProtocol $protocol = 'ipv4',
    String $interface      = '',
    Array[String] $options = [],
    String $zone,
    String $type           = 'External',
    $in_bandwidth          = '-',
    $out_bandwidth         = false,
) {
  if defined(Class['shorewall']) {
    include shorewall

    $interface_name = $interface ? {
        '' => $name,
        default => $interface,
    }

    if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
      concat::fragment { "shorewall-iface-ipv4-${name}":
        order   => '50',
        target  => '/etc/shorewall/interfaces',
        content => template('shorewall/iface.erb'),
      }

      if $::shorewall::traffic_control and $out_bandwidth {
        concat::fragment { "shorewall-tciface-ipv4-${name}":
          order   => '50',
          target  => '/etc/shorewall/tcinterfaces',
          content => "${name} ${type} ${in_bandwidth} ${out_bandwidth}\n",
        }
      }
    }
    if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
      concat::fragment { "shorewall-iface-ipv6-${name}":
        order   => '50',
        target  => '/etc/shorewall6/interfaces',
        content => template('shorewall/iface.erb'),
      }
    }
  } else {
    fail('Class shorewall must be declared before this resource can be used')
  }
}
