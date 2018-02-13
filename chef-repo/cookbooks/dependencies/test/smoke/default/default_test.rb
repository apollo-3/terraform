# # encoding: utf-8

# Inspec test for recipe dependencies::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

packages   = ['mysql-community-devel',
              'autoconf',
              'automake',
              'gcc',
              'gcc-c++',
              'libtool',
              'make']

gems       = ['mysql2', 'aws-sdk']

mysql_repo = "mysql-community"

describe yum.repo(mysql_repo) do
  it { should exist }
  it { should be_enabled }
end

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

gems.each do |gem_item|
  describe gem(gem_item, :chef) do
    it { should be_installed }
  end
end
