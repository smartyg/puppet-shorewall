# ex: si ts=4 sw=4 et

define shorewall::rule (
    $application   = '',
    $proto         = '',
    $port          = '',
    $sport         = '',
    $original_dest = '',
    $source,
    $dest,
    $action,
	Shorewall::TypeInetProtocol $protocol = 'all',
    $order         = '50',
) {
  if defined(Class['shorewall']) {
    include shorewall

    if $application == '' {
      validate_re($proto, '^(([0-9]+|tcp|udp|icmp|-)(?:,|$))+')
      #TODO: temporarly disable this check as it does not allow a list of ports, ex. 22,25,123
      #validate_re($port, ['^:?[0-9]+:?$', '^-$', '^[0-9]+[:,][0-9]+$'])
    } else {
      validate_re($application, '^[[:alnum:]]+$')
      validate_re($proto, '^-?$')
      validate_re($port, '^-?$')
    }
    if $original_dest != '' {
      validate_re($sport, '[^\s]+')
    }

    if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
      concat::fragment { "rule-ipv4-${name}":
        order   => $order,
        target  => '/etc/shorewall/rules',
        content => template('shorewall/rule.erb'),
      }
    }

    if (($protocol == 'ipv4' or $protocol == 'all') and $::shorewall::ipv4) {
      concat::fragment { "rule-ipv6-${name}":
        order   => $order,
        target  => '/etc/shorewall6/rules',
        content => template('shorewall/rule.erb'),
      }
    }
  } else {
    fail('Class shorewall must be declared before this resource can be used')
  }
}
