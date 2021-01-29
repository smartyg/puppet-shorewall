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
			concat::fragment { "snat-${name}":
				order   => $order,
				target  => '/etc/shorewall/snat',
				content => inline_template("<%= @action %> <%= empty(@source) ? '' : @source %> <%= @destination %> <%= empty(@proto) ? '' : @proto %> <%= empty(@dport) ? '' : @dport %> <%= empty(@ipsec) ? '' : @ipsec %> <%= empty(@mark) ? '' : @mark %> <%= empty(@user) ? '' : @user %> <%= empty(@switch) ? '' : @switch %> <%= empty(@origdest) ? '' : @origdest %> <%= empty(@probability) ? '' : @probability %>"),
			}
		}

		if (($protocol == 'ipv6' or $protocol == 'all') and $::shorewall::ipv6) {
			concat::fragment { "snat-${name}":
				order   => $order,
				target  => '/etc/shorewall6/snat',
				content => inline_template("<%= @action %> <%= @source.empty? ? '' : @source %> <%= @destination %> <%= @proto.empty? ? '' : @proto %> <%= @dport.empty? ? '' : @dport %> <%= @ipsec.empty? ? '' : @ipsec %> <%= @mark.empty? ? '' : @mark %> <%= @user.empty? ? '' : @user %> <%= @switch.empty? ? '' : @switch %> <%= @origdest.empty? ? '' : @origdest %> <%= @probability.empty? ? '' : @probability %>"),
			}
		}
	} else {
		fail('Class shorewall must be declared before this resource can be used')
	}
}
