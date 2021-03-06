require 'aws-sdk'

module BBnetes
  class DNS < AWS
    def initialize(aws_access_key,
                   aws_secret_key,
                   region,
                   node)
      @r53 = nil
      super(aws_access_key, aws_secret_key, region, node)
      begin
        @r53 = Aws::Route53::Client.new(credentials: @credentials,
                                        region:      @region)
      rescue
        Chef::Log.error("failed to create Route53 client")
      end
    end

    # Create Route53 DNS record
    def create_dns_record(record, public_ip, hosted_zone)
      fqdn = "#{record}.#{hosted_zone}."
      zone_id = get_hosted_zone_id_by_name(hosted_zone)
      resp = @r53.change_resource_record_sets({
        change_batch: {
          changes: [
            {
              action: "CREATE",
              resource_record_set: {
                name: fqdn,
                resource_records: [
                  {
                    value: public_ip,
                  },
                ],
                ttl: 60,
                type: "A",
              },
            },
          ]
        },
        hosted_zone_id: zone_id,
      })
      add_dns_name("#{record}.#{hosted_zone}")
    end

    # Delete Route53 DNS record
    def delete_dns_record(record, hosted_zone)
      fqdn = "#{record}.#{hosted_zone}."
      zone_id = get_hosted_zone_id_by_name(hosted_zone)
      records = list_zone_records(hosted_zone, fqdn)
      resp = @r53.change_resource_record_sets({
        change_batch: {
          changes: [
            {
              action: "DELETE",
              resource_record_set: records[0]
            }
          ]
        },
        hosted_zone_id: zone_id,
      })
      del_dns_name
    end

    # Check if A record already exist
    def record_exist?(dns_record, hosted_zone)
      list = get_record_by_name(dns_record, hosted_zone)
      list.any? ? true : false
    end

    private
    # Sets node attribute with a new Route53 DNS name
    def add_dns_name fqdn
      @node.default['custom_dns']['name'] = fqdn
    end

    # Deletes node attribute with Route53 DNS name
    def del_dns_name
     @node.default['custom_dns'].delete('name')
    end

    # Get the list of dns resources in a hosted zone
    def list_zone_records(hosted_zone, fqdn = "NA")
      zone_id   = get_hosted_zone_id_by_name(hosted_zone)
      opts      = {hosted_zone_id: zone_id,
                   max_items:      100}
      fqdn_opts = {start_record_name: fqdn,
                   start_record_type: "A"}
      opts = opts.merge(fqdn_opts) if fqdn != "NA"

      resp = @r53.list_resource_record_sets(opts)
      resp.resource_record_sets
    end

    # Get dns record by dns name in array
    def get_record_by_name(dns_name, hosted_zone)
      fqdn = "#{dns_name}.#{hosted_zone}."
      list = list_zone_records(hosted_zone)
      list.select { |record| record.name == fqdn }
    end

    # Get hosted zone id by name
    def get_hosted_zone_id_by_name(hosted_zone)
      resp = @r53.list_hosted_zones()
      out = resp.hosted_zones.select { |zone| zone.name == "#{hosted_zone}." }
      out.first.id
    end
  end
end