#
# Cookbook:: dependencies
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

yum_repository "mysql-community" do
  baseurl node['mysql']['repo']
  gpgcheck false
  action :nothing
end.run_action(:create)

node['required']['packages'].each do |pkg|
  yum_package "#{pkg}" do
    action :nothing
  end.run_action(:install)
end

node['required']['gems'].each do |gem_item|
  chef_gem gem_item do
    action :nothing
  end.run_action(:install)
end