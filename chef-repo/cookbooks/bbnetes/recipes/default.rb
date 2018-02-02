#
# Cookbook:: bbnetes
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

mysql_service "default" do
  port node['mysql']['port']
  version '5.5'
  initial_root_password node['mysql']['root_pwd']
  action [:create, :start]
end

bbnetes_db_user_config "db_user_allowed_host" do
  allowed_host '%'
  action [:match]
end

bbnetes_db_table "table_#{node['mysql']['table']}" do
  table node['mysql']['table']
  action [:create]
end