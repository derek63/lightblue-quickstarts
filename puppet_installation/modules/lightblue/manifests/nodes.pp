node default {
  case $::osfamily {
    RedHat  : { $supported = true }
    default : { 
      notice("The ${module_name} module is not supported on ${::osfamily} based systems")
      fail("The ${module_name} module is not supported on ${::osfamily} based systems") 
    }
  }

  include croot
  include puppet

  class { 'rhn':
    username => $::rhnuser,
    password => $::rhnpass,
  }->

  package { 'java-1.7.0-openjdk-devel':
    ensure => installed,
  }->


  class { 'jboss_as':
    jboss_dist     => 'eap.tar.gz',
    jboss_user     => 'eap',
    jboss_group    => 'eap',
    jboss_home     => '/usr/share/eap',
    staging_dir    => '/tmp/puppet-staging/jboss_as',
    standalone_tpl => 'jboss_as/standalone.xml.erb',
    download => true,
    username => $::rhnuser,
    password => $::rhnpass,
  }->

  mongodb_database { testdb:
    ensure   => present,
    tries    => 10,
    require  => Class['mongodb::server'],
  }->

  mongodb_user { testuser:
    ensure        => present,
    password_hash => mongodb_password('testuser', 'p@ssw0rd'),
    database      => testdb,
    roles         => ['readWrite', 'dbAdmin'],
    tries         => 10,
    require       => Class['mongodb::server'],
  }->

  package { 'package rest-metadata':
     provider => 'rpm',
     ensure => installed,
     source => "/tmp/rest-metadata.rpm"
  }->

  package { 'package rest-crud':
     provider => 'rpm',
     ensure => installed,
     source => "/tmp/rest-crud.rpm"
  }
}
