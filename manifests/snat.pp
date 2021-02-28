# ex: si ts=4 sw=4 et

define shorewall::snat (
	String $action,
	String $source                        = '',
	String $destination,
	String $proto                         = '',
	String $dport                         = '',
	String $ipsec                         = '',
	String $mark                          = '',
	String $user                          = '',
	String $switch                        = '',
	String $origdest                      = '',
	String $probability                   = '',
	Shorewall::TypeInetProtocol $protocol = 'all',
	$order                                = '50',
) {
	if defined(Class['shorewall']) {
		include shorewall

		if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
			concat::fragment { "snat-ipv4-${name}":
				order   => $order,
				target  => '/etc/shorewall/snat',
				content => template('shorewall/snat.erb'),
			}
		}

		if (($protocol == 'ipv6' or $protocol == 'all') and $::shorewall::ipv6) {
			concat::fragment { "snat-ipv6-${name}":
				order   => $order,
				target  => '/etc/shorewall6/snat',
				content => template('shorewall/snat.erb'),
			}
		}
	} else {
		fail('Class shorewall must be declared before this resource can be used')
	}
}
