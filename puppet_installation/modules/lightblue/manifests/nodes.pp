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
  }

  package { 'java-1.7.0-openjdk-devel':
    ensure => installed,
  }

  $central = {
    id => "myrepo",
    username => "myuser",
    password => "mypassword",
    url => "http://repo.acme.com",
    mirrorof => "external:*",      # if you want to use the repo as a mirror, see maven::settings below
  }
  
  $proxy = {
    active => true, #Defaults to true
    protocol => 'http', #Defaults to 'http'
    host => 'http://proxy.acme.com',
    username => 'myuser', #Optional if proxy does not require
    password => 'mypassword', #Optional if proxy does not require
    nonProxyHosts => 'www.acme.com', #Optional, provides exceptions to the proxy
  }

  # Install Maven
  class { "maven::maven":
    version => "3.2.1", # version to install
    # you can get Maven tarball from a Maven repository instead than from Apache servers, optionally with a user/password
    repo => {
      #url => "http://repo.maven.apache.org/maven2",
      #username => "",
      #password => "",
    }
  } ->

  # Setup a .mavenrc file for the specified user
  maven::environment { 'maven-env' : 
      user => 'root',
      # anything to add to MAVEN_OPTS in ~/.mavenrc
      maven_opts => '-Xmx1384m',       # anything to add to MAVEN_OPTS in ~/.mavenrc
      maven_path_additions => "",      # anything to add to the PATH in ~/.mavenrc

  } ->

  # Create a settings.xml with the repo credentials
  maven::settings { 'maven-user-settings' :
    mirrors => [$central], # mirrors entry in settings.xml, uses id, url, mirrorof from the hash passed
    servers => [$central], # servers entry in settings.xml, uses id, username, password from the hash passed
    proxies => [$proxy], # proxies entry in settings.xml, active, protocol, host, username, password, nonProxyHosts
    user    => 'maven',
  }

  # defaults for all maven{} declarations
  Maven {
    user  => "maven", # you can make puppet run Maven as a specific user instead of root, useful to share Maven settings and local repository
    group => "maven", # you can make puppet run Maven as a specific group
    repos => "http://repo.maven.apache.org/maven2"
  } 

  class { 'jboss_as':
    jboss_dist     => 'eap.tar.gz',
    jboss_user     => 'jboss',
    jboss_group    => 'eap',
    jboss_home     => '/usr/share/eap',
    staging_dir    => '/tmp/puppet-staging/jboss_as',
    standalone_tpl => 'jboss_as/standalone.xml.erb',
    download => true,
    username => $::rhnuser,
    password => $::rhnpass,
  }

  class {'::mongodb::server':
    auth => true,
  }

  mongodb::db { 'testdb':
    user          => 'user1',
    password_hash => 'a15fbfca5e3a758be80ceaf42458bcd8',
  }

  exec { 'build-lightblue':
    path    => $::path,
    user    => $::remoteuser,
    cwd     => "/home/${::remoteuser}/",
    command => 'rm -rf lightblue && git clone https://github.com/lightblue-platform/lightblue && cd lightblue && mvn -q clean install && mv rest/crud/target/rest-crud* /tmp/rest-crud.war && mv rest/metadata/target/rest-metadata* /tmp/rest-metadata.war ',
  }

  jboss_as::deploy { 'rest-metadata.war':
    pkg         => 'rest-metadata.war', 
    tmp     => true,
  }
  jboss_as::deploy { 'rest-crud.war':
    pkg         => 'rest-crud.war', 
    tmp     => true,
  }

}
