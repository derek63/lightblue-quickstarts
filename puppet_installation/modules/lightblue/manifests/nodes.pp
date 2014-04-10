node default {
  case $::osfamily {
    RedHat  : { $supported = true }
    default : { fail("The ${module_name} module is not supported on ${::osfamily} based systems") }
  }
  include croot
  include puppet
  class { 'rhn':
    username => $::RHN_USER,
    username => $::RHN_PASS,
    force    => true,
  }
}
