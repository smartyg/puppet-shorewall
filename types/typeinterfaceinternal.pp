# vim: set tw=2 sw=2 et

type Shorewall::TypeInterfaceInternal = Struct[{'interface' => String, 'zone' => String, 'protocol' => Shorewall::TypeInetProtocol, 'options' => Array}]
