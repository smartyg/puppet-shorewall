# ex: si ts=4 sw=4 et

define shorewall::tcpri (
	Shorewall::TypeInetProtocol $protocol = 'ipv4',
	Integer $band     = 3,
	String $proto     = '-',
	String $port      = '-',
	String $address   = '-',
	String $interface = '-',
) {
	if defined(Class['shorewall']) and $::shorewall::traffic_control {
		include shorewall

		if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
			if $::shorewall::traffic_control {
				concat::fragment { "shorewall-tcpri-ipv4-${band}-${proto}-${port}-${address}-${interface}":
					order   => '50',
					target  => '/etc/shorewall/tcpri',
					content => "${band} ${proto} ${port} ${address} ${interface}\n",
				}
			}
		}
		if (($protocol == 'ipv6' or $protocol == 'all') and $::shorewall::ipv6) {
			if $::shorewall::traffic_control {
				concat::fragment { "shorewall-tcpri-ipv6-${band}-${proto}-${port}-${address}-${interface}":
					order   => '50',
					target  => '/etc/shorewall6/tcpri',
					content => "${band} ${proto} ${port} ${address} ${interface}\n",
				}
			}
		}
	} else {
		fail('Class shorewall must be declared before this resource can be used')
	}
}
