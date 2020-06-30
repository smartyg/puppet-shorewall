define shorewall::config (
    $value,
    $ipv4          = $::shorewall::ipv4,
    $ipv6          = $::shorewall::ipv6,
) {
    include shorewall

    if ($ipv4 and $::shorewall::ipv4) {
        concat::fragment { "shorewall-config-${name}":
            order   => '01',
            target  => '/etc/shorewall/shorewall.conf',
            content => "${name} = ${value}",
        }
    }

    if ($ipv6 and $::shorewall::ipv6) {
        concat::fragment { "shorewall6-config-${name}":
            order   => '01',
            target  => '/etc/shorewall6/shorewall6.conf',
            content => "${name} = ${value}",
        }
    }
}
