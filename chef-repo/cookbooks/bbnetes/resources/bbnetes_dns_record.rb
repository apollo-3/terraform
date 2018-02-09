resource_name :bbnetes_dns_record

property :dns_record, String, name_property: true
property :hosted_zone, String, required: true
property :aws_access_key, String, required: true
property :aws_secret_key, String, required: true
property :region, String, default: "eu-west-2"

default_action :create

load_current_value do
end

action :create do
  dns = BBnetes::DNS.new(new_resource.aws_access_key,
                         new_resource.aws_secret_key,
                         new_resource.region,
                         node)
  return if dns.record_exist?(new_resource.dns_record, new_resource.hosted_zone)

  ec2 = BBnetes::EC2.new(new_resource.aws_access_key,
                         new_resource.aws_secret_key,
                         new_resource.region,
                         node)
  public_ip = ec2.get_node_public_ip
  dns.create_dns_record(new_resource.dns_record, public_ip,
                        new_resource.hosted_zone)
  new_resource.updated_by_last_action(true)
end

action :delete do
  dns = BBnetes::DNS.new(new_resource.aws_access_key,
                         new_resource.aws_secret_key,
                         new_resource.region,
                         node)
  return unless dns.record_exist?(new_resource.dns_record, new_resource.hosted_zone)
  dns.delete_dns_record(new_resource.dns_record, new_resource.hosted_zone)
  new_resource.updated_by_last_action(true)
end

action_class do
  include BBnetes
end