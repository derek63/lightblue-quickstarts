class puppet {
  package { 'vim-enhanced':
    ensure => installed,
  }
  file { '/usr/local/bin/papply':
    source => 'puppet:///modules/puppet/papply.sh',
    mode   => '0755',
  }
  file { '/usr/local/bin/update_quickstarts':
    source => 'puppet:///modules/puppet/update_quickstarts.sh',
    mode   => '0755',
  }
}
