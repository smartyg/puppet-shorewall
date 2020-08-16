# ex: si ts=4 sw=4 et

define shorewall::port (
    $application = '',
    $proto       = '',
    $port        = '',
    $source,
    $action      = 'ACCEPT',
    $order       = '50',
    $ipv4        = $::shorewall::ipv4,
    $ipv6        = $::shorewall::ipv6,
) {
    shorewall::rule { "port-${name}":
        application => $application,
        proto       => $proto,
        port        => $port,
        source      => $source,
        destination => '$FW',
        action      => $action,
        order       => $order,
        protocol    => 'all',
    }
}
