#
# Cookbook:: bbnetes
# Recipe:: app
#
# Copyright:: 2018, The Authors, All Rights Reserved.

tomcat_install 'tomcat' do
  install_path '/opt/apps/tomcat'
  version '7.0.84'
  verify_checksum false
  tarball_validate_ssl false
  tomcat_user 'tomcat'
  tomcat_group 'tomcat'
  tomcat_user_shell '/bin/bash'
end

include_recipe 'java'

tomcat_service 'tomcat' do
  install_path '/opt/apps/tomcat'
  tomcat_user 'tomcat'
  tomcat_group 'tomcat'
  env_vars [{'host' => 'X'},
            {'port' => 'X'},
            {'user' => 'X'},
            {'port' => 'X'}]
  action :start
end