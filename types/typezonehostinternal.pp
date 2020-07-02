# vim: set tw=2 sw=2 et

type Shorewall::TypeZoneHostInternal = Struct[{'zone' => String, 'protocol' => Shorewall::TypeInetProtocol, 'interface' => String, 'address' => String}]
