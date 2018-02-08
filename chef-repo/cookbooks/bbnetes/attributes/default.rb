default['mysql']['table']          = "test"

default['java']['jdk_version']                            = '8'
default['java']['install_flavor']                         = 'oracle'
default['java']['oracle']['accept_oracle_download_terms'] = true

default['tomcat']['home']      = "/opt/apps/tomcat"
default['tomcat']['user']      = "tomcat"
default['tomcat']['group']     = "tomcat"
default['tomcat']['version']   = "7.0.84"
default['tomcat']['shell']     = "/bin/bash"
default['tomcat']['java_opts'] = {"java.net.preferIPv4Stack"     => "true",
                                  "java.net.preferIPv4Addresses" => "true"}