# ex: si ts=4 sw=4 et

define shorewall::snat (
	String $action,
	Optional[String] $source              = undef,
	String $destination,
	Optional[String] $proto               = undef,
	Optional[String] $dport               = undef,
	Optional[String] $ipsec               = undef,
	Optional[String] $mark                = undef,
	Optional[String] $user                = undef,
	Optional[String] $switch              = undef,
	Optional[String] $origdest            = undef,
	Optional[String] $probability         = undef,
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
