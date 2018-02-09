#
# Cookbook:: bbnetes
# Recipe:: db
#
# Copyright:: 2018, The Authors, All Rights Reserved.

dbg_db   = search(:db, "id:mysql").first
dbg_keys = search(:keys, "id:aws").first

node.default['mysql']['pass'] = dbg_db['password']
aws_access_key                = dbg_keys['aws_access_key']
aws_secret_key                = dbg_keys['aws_secret_key']

mysql_service "default" do
  port node['mysql']['port']
  version '5.5'
  initial_root_password node['mysql']['pass']
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

bbnetes_dns_record "db" do
  hosted_zone node['dns']['zone']
  aws_access_key aws_access_key
  aws_secret_key aws_secret_key
  action :create
end