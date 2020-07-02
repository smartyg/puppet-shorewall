# vim: set tw=2 sw=2 et

type Shorewall::TypePolicyInternal = Struct[{'source' => String, 'destination' => String, 'action' => String, 'protocol' => Shorewall::TypeInetProtocol, 'log_level' => String}]
