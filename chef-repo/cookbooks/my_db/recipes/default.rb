#
# Cookbook:: my_db
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

yum_repository "mysql-community" do
  baseurl node['mysql']['repo']
  gpgcheck false
  action :create   
end

mysql_service "#{node['mysql']['service']}" do
  port node['mysql']['port']
  version node['mysql']['version']
  initial_root_password node['mysql']['root_pwd']
  action [:create, :start]
end

mysql_user_config "root_config" do
  allowed_host '%'
  action [:match]
end