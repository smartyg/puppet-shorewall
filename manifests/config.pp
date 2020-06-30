# vim: set tw=2 sw=2 et

define shorewall::config (
    String $value,
    Boolean $ipv4 = $::shorewall::ipv4,
    Boolean $ipv6 = $::shorewall::ipv6,
) {
    include shorewall

    if ($ipv4 and $::shorewall::ipv4) {
        concat::fragment { "shorewall-config-${name}":
            order   => '01',
            target  => '/etc/shorewall/shorewall.conf',
            content => "${name} = ${value}\n",
            before  => Anchor['shorewall'],
        }
    }

    if ($ipv6 and $::shorewall::ipv6) {
        concat::fragment { "shorewall6-config-${name}":
            order   => '01',
            target  => '/etc/shorewall6/shorewall6.conf',
            content => "${name} = ${value}\n",
            before  => Anchor['shorewall6'],
        }
    }
}
