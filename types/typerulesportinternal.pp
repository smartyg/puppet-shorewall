# vim: set tw=2 sw=2 et

type Shorewall::TypeRulesPortInternal = Struct[{'source' => String, 'destination' => String, 'proto' => String, 'port' => String, 'action' => String, 'protocol' => Shorewall::TypeInetProtocol}]
