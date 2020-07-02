# vim: set tw=2 sw=2 et

type Shorewall::TypeZoneOnlyInternal = Struct[{'zone' => String, 'protocol' => Shorewall::TypeInetProtocol}]
