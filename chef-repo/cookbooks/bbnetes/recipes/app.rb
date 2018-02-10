#
# Cookbook:: bbnetes
# Recipe:: app
#
# Copyright:: 2018, The Authors, All Rights Reserved.

Chef::Resource.send(:include, BBnetes::Helper)

# Set some node attributes to provision application
BBnetes::Helper.set_db_ip_attribute(node)
BBnetes::Helper.set_db_password_attribute(node)
java_opts = BBnetes::Helper.build_java_opts_string(node)

# Read aws credentials from a Data Bag
dbg_keys = search(:keys, "id:aws").first
aws_access_key                = dbg_keys['aws_access_key']
aws_secret_key                = dbg_keys['aws_secret_key']

include_recipe 'java'

tomcat_install 'tomcat' do
  install_path node['tomcat']['home']
  version node['tomcat']['version']
  verify_checksum false
  tarball_validate_ssl false
  tomcat_user node['tomcat']['user']
  tomcat_group node['tomcat']['group']
  tomcat_user_shell node['tomcat']['shell']
end

web_apps_folder = "#{node['tomcat']['home']}/webapps"
cookbook_file "#{web_apps_folder}/app.war" do
  source "app.war"
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0755'
  action :create
  only_if { ::Dir.exist?(web_apps_folder) }
end

tomcat_service 'tomcat' do
  install_path node['tomcat']['home']
  tomcat_user node['tomcat']['user']
  tomcat_group node['tomcat']['group']
  env_vars [{'JAVA_OPTS' => java_opts.strip}]
  action :start
end

bbnetes_dns_record "app" do
  hosted_zone node['dns']['zone']
  aws_access_key aws_access_key
  aws_secret_key aws_secret_key
  action :create
end