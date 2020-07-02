# vim: set tw=2 sw=2 et

type Shorewall::TypeRulesAplicationInternal = Struct[{'source' => String, 'destination' => String, 'application' => String, 'action' => String, 'protocol' => Shorewall::TypeInetProtocol}]
