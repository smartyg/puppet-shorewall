# vim: set tw=2 sw=2 et

class shorewall (
  Boolean $ipv4                                = true,
  Boolean $ipv6                                = true,
  Boolean $ipv4_tunnels                        = false,
  Boolean $ipv6_tunnels                        = false,
  String $default_policy                       = 'REJECT',
  Boolean $ip_forwarding                       = false,
  Boolean $traffic_control                     = false,
  String $traffic_control_priomap              = '',
  String $maclist_ttl                          = '',
  String $maclist_disposition                  = 'REJECT',
  Boolean $log_martians                        = true,
  Variant[Boolean, Enum['keep']] $route_filter = true,
  String $default_zone_entry                   = "fw firewall\n",
  Array $blacklist                             = ["NEW","INVALID","UNTRACKED"],
  Boolean $purge_config_dir                    = true,
  Boolean $manage_service                      = true,
  Boolean $manage_package                      = true,
  Shorewall::TypeSettings $config_options      = [],
  Shorewall::TypeInterfaces $interfaces        = [],
  Shorewall::TypeZones $zones                  = [],
  Shorewall::TypePolicies $policies            = [],
  Shorewall::TypeRules $rules                  = [],
  Boolean $zones_have_hosts                    = true,
) {
  include shorewall::defaults

  $blacklist_filename = $::shorewall::defaults::blacklist_filename
  $header_lead = $::shorewall::defaults::header_lead
  $mangle_filename = $::shorewall::defaults::mangle_filename
  $service_restart = $::shorewall::defaults::service_restart
  $service6_restart = $::shorewall::defaults::service6_restart

  # These anchor are used because both package install and service resource are optional, it's unsure which one is availible.
  anchor { 'shorewall': }
  anchor { 'shorewall6': }

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  if $ipv4 {
    if $manage_package {
      package { 'shorewall':
        ensure => latest,
        before => [
          File['/etc/shorewall'],
          Anchor['shorewall'],
        ],
        notify => Anchor['shorewall'],
      }
    }

    file { '/etc/shorewall':
      ensure  => directory,
      purge   => $purge_config_dir,
    }

    concat { [
      '/etc/shorewall/shorewall.conf',
      '/etc/shorewall/zones',
      '/etc/shorewall/interfaces',
      '/etc/shorewall/policy',
      '/etc/shorewall/rules',
      "/etc/shorewall/${blacklist_filename}",
      '/etc/shorewall/proxyarp',
      '/etc/shorewall/hosts',
      "/etc/shorewall/${mangle_filename}",
      '/etc/shorewall/conntrack',
      '/etc/shorewall/stoppedrules',
      '/etc/shorewall/snat',
    ]:
      mode   => '0644',
      before => Anchor['shorewall'],
      notify => Anchor['shorewall'],
    }

    # shorewall.conf
    concat::fragment { 'shorewall-preamble':
      order   => '00',
      target  => '/etc/shorewall/shorewall.conf',
      content => "# This file is managed by puppet\n# Edits will be lost\n",
    }

    # ipv4 zones
    concat::fragment { 'zones-preamble':
      order   => '00',
      target  => '/etc/shorewall/zones',
      content => "# This file is managed by puppet\n# Edits will be lost\n",
    }

    concat::fragment { 'shorewall-zones-local':
      order   => '01',
      target  => '/etc/shorewall/zones',
      content => $default_zone_entry,
    }

    # ipv4 interfaces
    concat::fragment { 'interfaces-preamble':
      order   => '00',
      target  => '/etc/shorewall/interfaces',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv4 policy
    concat::fragment { 'policy-preamble':
      order   => '00',
      target  => '/etc/shorewall/policy',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv4 rules
    concat::fragment { 'rules-preamble':
      order   => '00',
      target  => '/etc/shorewall/rules',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv4 rules SECTION NEW
    concat::fragment { 'rules-section-new':
      order   => '00',
      target  => '/etc/shorewall/rules',
      content => template('shorewall/rules-section-new.erb'),
    }

    # ipv4 blacklist
    concat::fragment { "${blacklist_filename}-preamble":
      order   => '00',
      target  => "/etc/shorewall/${blacklist_filename}",
      source  => "puppet:///modules/shorewall/${blacklist_filename}_header",
    }

    # ipv4 hosts
    concat::fragment { 'hosts-preamble':
      order   => '00',
      target  => '/etc/shorewall/hosts',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv4 tunnels (composed)
    if $ipv4_tunnels {
      concat { '/etc/shorewall/tunnels':
        mode   => '0644',
        notify => Service['shorewall'],
      }

      concat::fragment { 'tunnels-preamble':
        order   => '00',
        target  => '/etc/shorewall/tunnels',
        content => "# This file is managed by puppet\n# Changes will be lost\n",
      }
    } else {
      file { '/etc/shorewall/tunnels':
        ensure => absent,
        notify => Service['shorewall'],
      }
    }

    # ipv4 proxyarp
    concat::fragment { 'proxyarp-preamble':
      order   => '00',
      target  => '/etc/shorewall/proxyarp',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv4 tc rules
    concat::fragment { "${mangle_filename}-preamble":
      order   => '00',
      target  => "/etc/shorewall/${mangle_filename}",
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    #ipv4 conntrack
    concat::fragment { 'conntrack-header':
      order   => '00',
      target  => '/etc/shorewall/conntrack',
      source => 'puppet:///modules/shorewall/conntrack_header',
    }

    # ipv4 stoppedrules
    concat::fragment { 'stoppedrules-preamble':
      order   => '00',
      target  => '/etc/shorewall/stoppedrules',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv4 snat
    concat::fragment { 'snat-preamble':
		order   => '00',
		target  => '/etc/shorewall/snat',
		content => "# This file is managed by puppet\n# Changes will be lost\n",
	}

    if $traffic_control {
      concat { [
        '/etc/shorewall/tcinterfaces',
        '/etc/shorewall/tcpri',
      ]:
        mode   => '0644',
        notify => Service['shorewall'],
      }

      # ipv4 tc interfaces
      concat::fragment { 'tcinterfaces-preamble':
        order   => '00',
        target  => '/etc/shorewall/tcinterfaces',
        content => "# This file is managed by puppet\n# Changes will be lost\n",
      }

      # ipv4 tc priorities
      concat::fragment { 'tcpri-preamble':
        order   => '00',
        target  => '/etc/shorewall/tcpri',
        content => "# This file is managed by puppet\n# Changes will be lost\n",
      }
    } else {
      file { [
        '/etc/shorewall/tcinterfaces',
        '/etc/shorewall/tcpri',
      ]:
        ensure => absent,
      }
    }

    if $manage_service
    {
      service { 'shorewall':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Anchor['shorewall'],
        subscribe  => Anchor['shorewall'],
      }
    }
  }

  if $ipv6 {
    if $manage_package {
      package { 'shorewall6':
        ensure => latest,
        before => [
          File['/etc/shorewall6'],
          Anchor['shorewall6'],
        ],
        notify => Anchor['shorewall6'],
      }
    }

    file { '/etc/shorewall6':
      ensure  => directory,
      purge   => $purge_config_dir,
    }

    concat { [
      '/etc/shorewall6/shorewall6.conf',
      '/etc/shorewall6/zones',
      '/etc/shorewall6/interfaces',
      '/etc/shorewall6/policy',
      '/etc/shorewall6/rules',
      "/etc/shorewall6/${blacklist_filename}",
      '/etc/shorewall6/hosts',
      '/etc/shorewall6/routestopped',
      '/etc/shorewall6/conntrack',
      '/etc/shorewall6/stoppedrules',
      '/etc/shorewall6/snat',
    ]:
      mode   => '0644',
      before => Anchor['shorewall6'],
      notify => Anchor['shorewall6'],
    }

    # shorewall6.conf
    concat::fragment { 'shorewall6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/shorewall6.conf',
      content => "# This file is managed by puppet\n# Edits will be lost\n",
    }

    # ipv6 zones
    concat::fragment { 'zones6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/zones',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    concat::fragment { 'shorewall6-zones-local':
      order   => '01',
      target  => '/etc/shorewall6/zones',
      content => $default_zone_entry,
    }

    # ipv6 interfaces
    concat::fragment { 'interfaces6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/interfaces',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv6 policy (default DROP)
    concat::fragment { 'policy6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/policy',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv6 rules
    concat::fragment { 'rules6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/rules',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv6 rules SECTION NEW
    concat::fragment { 'rules6-section-new':
      order   => '00',
      target  => '/etc/shorewall6/rules',
      content => template('shorewall/rules-section-new.erb'),
    }

    # ipv6 blacklist
    concat::fragment { "${blacklist_filename}-ipv6-preamble":
      order   => '00',
      target  => "/etc/shorewall6/${blacklist_filename}",
      source  => "puppet:///modules/shorewall/${blacklist_filename}_header",
    }

    # ipv6 hosts
    concat::fragment { 'hosts6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/hosts',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv6 tunnels
    if $ipv6_tunnels {
      concat { '/etc/shorewall6/tunnels':
        mode   => '0644',
        notify => Service['shorewall6'],
      }

      concat::fragment { 'tunnels6-preamble':
        order   => '00',
        target  => '/etc/shorewall6/tunnels',
        content => "# This file is managed by puppet\n# Changes will be lost\n",
      }
    } else {
      file { '/etc/shorewall6/tunnels':
        ensure => absent,
        notify => Service['shorewall6'],
      }
    }

    # ipv6 routestopped
    concat::fragment { 'routestopped6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/routestopped',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv6 snat
    concat::fragment { 'snat6-preamble':
      order   => '00',
      target  => '/etc/shorewall6/snat',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    # ipv6 conntrack
    concat::fragment { 'conntrack6-header':
      order   => '00',
      target  => '/etc/shorewall6/conntrack',
      source  => 'puppet:///modules/shorewall/conntrack6_header',
    }

    # ipv6 conntrack
    concat::fragment { 'stoppedrules6-header':
      order   => '00',
      target  => '/etc/shorewall6/stoppedrules',
      content => "# This file is managed by puppet\n# Changes will be lost\n",
    }

    if $traffic_control {
		concat { [
			'/etc/shorewall6/tcinterfaces',
			'/etc/shorewall6/tcpri',
		]:
			mode   => '0644',
			notify => Service['shorewall'],
		}

		# ipv4 tc interfaces
		concat::fragment { 'tcinterfaces6-preamble':
			order   => '00',
			target  => '/etc/shorewall6/tcinterfaces',
			content => "# This file is managed by puppet\n# Changes will be lost\n",
		}

		# ipv4 tc priorities
		concat::fragment { 'tcpri6-preamble':
			order   => '00',
			target  => '/etc/shorewall6/tcpri',
			content => "# This file is managed by puppet\n# Changes will be lost\n",
		}
	} else {
		file { [
			'/etc/shorewall6/tcinterfaces',
			'/etc/shorewall6/tcpri',
		]:
		ensure => absent,
		}
	}

    if $manage_service
    {
      service { 'shorewall6':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Anchor['shorewall6'],
        subscribe  => Anchor['shorewall6'],
      }
    }
  }

  shorewall::config { 'IP_FORWARDING':
    value => $ip_forwarding ? { true => "Yes", false => "No", 'keep' => "Keep" },
  }
  shorewall::config { 'LOG_MARTIANS':
    value => $log_martians ? { true => "Yes", false => "No", 'keep' => "Keep" },
  }
  shorewall::config { 'MACLIST_TTL':
    value => $maclist_ttl,
  }
  shorewall::config { 'MACLIST_DISPOSITION':
    value => $maclist_disposition,
  }
  shorewall::config { 'TC_ENABLED':
    value => $traffic_control ? { true => "Simple", false => "Internal" },
  }
  if $traffic_control == true and $traffic_control_priomap != '' {
	shorewall::config { 'TC_PRIOMAP':
		value => $traffic_control_priomap,
	}
  }
  shorewall::config { 'ROUTE_FILTER':
    value => $route_filter ? { true => 'Yes', false => 'No', 'keep' => 'Keep' },
    ipv6  => false,
  }

  each($config_options) |Integer $n, Hash[String, String, 1, 1] $option| {
    each($option) |$item| {
      shorewall::config { $item[0]:
        value => $item[1],
      }
    }
  }

  each($interfaces) |Shorewall::TypeInterfaceInternal $item| {
    shorewall::interface { "iface-${item['protocol']}-${item['interface']}":
      * => $item,
    }
  }

  if ($default_policy != '') {
    shorewall::policy { 'policy-all-default':
      source      => 'all',
      destination => 'all',
      action      => $default_policy,
      order       => '99',
      protocol    => 'all',
    }
  }

  each($policies) |Integer $n, Shorewall::TypePolicyInternal $item| {
    $policy_order = 10 + $n
    shorewall::policy { "policy-${item['protocol']}-${item['source']}-${item['destination']}":
      *     => $item,
      order => String($policy_order),
    }
  }


  each($zones) |Shorewall::TypeZoneInternal $item| {
    shorewall::zone { "zone-${item['protocol']}-${item['zone']}":
      zone     => $item['zone'],
      protocol => $item['protocol'],
    }

    if is_a($item, Shorewall::TypeZoneHostInternal) {
      shorewall::host { "host-${item['protocol']}-${item['zone']}":
        zone      => $item['zone'],
        interface => $item['interface'],
        addresses => $item['address'],
        protocol  => $item['protocol'],
      }
    }
  }

  each($rules) |Integer $n, Shorewall::TypeRuleInternal $item| {
    $rule_order = 10 + $n

    if is_a($item, Shorewall::TypeRuleAplicationInternal) {
      shorewall::rule { "rule-${item['protocol']}-${item['source']}-${item['destination']}-${item['application']}":
        *     => $item,
        order => String($rule_order),
      }
    }
    elsif is_a($item, Shorewall::TypeRulePortInternal) {
      shorewall::rule { "rule-${item['protocol']}-${item['source']}-${item['destination']}-${item['proto']}-${item['port']}":
        *     => $item,
        order => String($rule_order),
      }
    }
  }
}
