class croot {
  file { '/usr/local/bin/croot':
    source => 'puppet://modules/puppet/croot.sh',
    mode   => '0755',
  }
}

define croot::check {
  exec { 'Check root grant': 
    command => '$(id -u)',
    path    => [ '/usr/local/bin/', '/bin/', '/usr/bin/' ],
 }
}
