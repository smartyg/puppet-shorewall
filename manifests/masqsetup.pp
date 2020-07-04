class shorewall::masqsetup
{
  include shorewall
  $ipv4 = $::shorewall::ipv4

  if $ipv4 {
    concat { '/etc/shorewall/masq':
      mode   => '0644',
      before => Anchor['shorewall::shorewall'],
      notify => Anchor['shorewall::shorewall'],
    } 

    # ipv4 masquerading
    concat::fragment { 'masq-preamble':
      order   => '00',
      target  => '/etc/shorewall/masq',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }
  }
}
