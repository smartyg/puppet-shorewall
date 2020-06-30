# vim: set tw=2 sw=2 et

define shorewall::config (
  String $value,
  Boolean $ipv4 = $::shorewall::ipv4,
  Boolean $ipv6 = $::shorewall::ipv6,
) {
  include shorewall

  # shorewall options are capitalized
  $option = upcase($name)

  if ($ipv4 and $::shorewall::ipv4) {
    concat::fragment { "shorewall-config-${option}":
      order   => '01',
      target  => '/etc/shorewall/shorewall.conf',
      content => "${option}=${value}\n",
      before  => Anchor['shorewall'],
    }
  }

  if ($ipv6 and $::shorewall::ipv6) {
    concat::fragment { "shorewall6-config-${option}":
      order   => '01',
      target  => '/etc/shorewall6/shorewall6.conf',
      content => "${option}=${value}\n",
      before  => Anchor['shorewall6'],
    }
  }
}
