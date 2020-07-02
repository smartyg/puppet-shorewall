# vim: set tw=2 sw=2 et

type Shorewall::TypeZonesOnlyInternal = Struct[{'zone' => String, 'protocol' => Shorewall::TypeInetProtocol}]
