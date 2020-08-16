# ex: si ts=4 sw=4 et

define shorewall::zone (
  String $zone                = '',
  Array[String] $parent_zones = [],
  Shorewall::TypeInetProtocol $protocol = 'all',
  $options                    = '-',
  $in_options                 = '-',
  $out_options                = '-',
  $order                      = '50',
  Optional[String] $interface = undef,
  Optional[String] $addresses = undef,
) {
  if defined(Class['shorewall']) {
    include shorewall

    $zone_name = $zone ? {
        '' => $name,
        default => $zone,
    }

    if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
      concat::fragment { "zone-ipv4-${name}":
        order   => $order,
        target  => '/etc/shorewall/zones',
        content => template('shorewall/zone.erb'),
      }
    }
    if (($protocol == 'ipv6' or $protocol == 'all') and $::shorewall::ipv6) {
      concat::fragment { "zone-ipv6-${name}":
        order   => $order,
        target  => '/etc/shorewall6/zones',
        content => template('shorewall/zone.erb'),
      }
    }
    if $interface != undef and $address != undef {
      shorewall::host { "host-${protocol}-${zone}-${interface}":
        zone      => $zone,
        interface => $interface,
        addresses => $addresses,
        protocol  => $protocol,
      }
    }
  } else {
    fail('Class shorewall must be declared before this resource can be used')
  }
}
