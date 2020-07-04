# ex: si ts=4 sw=4 et

define shorewall::stoppedrules (
    $action       = '',
    $source       = '',
    $dest         = '',
    $proto        = '',
    $dest_ports   = [],
    $source_ports = [],
    $ipv4         = $::shorewall::ipv4,
    $ipv6         = $::shorewall::ipv6,
    $order        = '50',
) {
    if $ipv4 {
        concat::fragment { "stoppedrules-ipv4-${name}":
            order   => $order,
            target  => '/etc/shorewall/stoppedrules',
            content => template('shorewall/stoppedrules.erb'),
        }
    }

    if $ipv6 {
        concat::fragment { "stoppedrules-ipv6-${name}":
            order   => $order,
            target  => '/etc/shorewall6/stoppedrules',
            content => template('shorewall/stoppedrules.erb'),
        }
    }
}
