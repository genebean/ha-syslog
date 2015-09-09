resources { 'host': purge => true }

host { 'localhost':
  ensure       => 'present',
  host_aliases => ['localhost.localdomain', 'localhost4', 'localhost4.localdomain4'],
  ip           => '127.0.0.1',
  target       => '/etc/hosts',
}
host { 'log1':
  ensure => 'present',
  ip     => '172.28.128.22',
  target => '/etc/hosts',
}
host { 'log2':
  ensure => 'present',
  ip     => '172.28.128.23',
  target => '/etc/hosts',
}
host { 'raft':
  ensure => 'present',
  ip     => '172.28.128.21',
  target => '/etc/hosts',
}
