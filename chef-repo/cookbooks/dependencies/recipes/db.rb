#
# Cookbook:: dependencies
# Recipe:: db
#
# Copyright:: 2018, The Authors, All Rights Reserved.

yum_repository "mysql-community" do
  baseurl node['mysql']['repo']
  gpgcheck false
  action :create
end

node['db']['packages'].each do |pkg|
  yum_package "#{pkg}"
end

chef_gem 'mysql2'