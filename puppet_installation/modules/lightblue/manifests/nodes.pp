node default {
  case $::osfamily {
    RedHat  : { $supported = true }
    default : { fail("The ${module_name} module is not supported on ${::osfamily} based systems") }
  }
  notice("The \$username value is: ${::RHN_PASS} // $::RHN_PASS ")
  include croot
  include puppet
  class { 'rhn':
    username => $::RHN_USER,
    password => $::RHN_PASS,
    force    => true,
  }
}
