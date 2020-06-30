# ex: si ts=4 sw=4 et

define shorewall::policy (
    String $source,
    String $dest,
    String $action,
    String $order     = '50',
    String $log_level = '-',
    Boolean $ipv4     = $::shorewall::ipv4,
    Boolean $ipv6     = $::shorewall::ipv6,
) {
    validate_re($order, ['^\d+$'], "Valid values for $order must be an integer.")

    if $ipv4 {
        concat::fragment { "policy-ipv4-${action}-${source}-to-${dest}":
            order   => $order,
            target  => '/etc/shorewall/policy',
            content => "${source} ${dest} ${action} ${log_level}\n",
        }
    }

    if $ipv6 {
        concat::fragment { "policy-ipv6-${action}-${source}-to-${dest}":
            order   => $order,
            target  => '/etc/shorewall6/policy',
            content => "${source} ${dest} ${action} ${log_level}\n",
        }
    }
}
