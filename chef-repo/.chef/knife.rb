current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               "#{current_dir}/admin.pem"
#validation_client_name   'myorg'
#validation_key           "#{current_dir}/validator.pem"
validation_key           "/nonexist"
chef_server_url          'https://ip-192-168-0-10.eu-west-2.compute.internal/organizations/myorg'
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
