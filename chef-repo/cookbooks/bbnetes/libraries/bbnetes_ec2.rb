require 'aws-sdk'

module BBnetes
  class EC2 < AWS
    def initialize(aws_access_key,
                   aws_secret_key,
                   region,
                   node)
      @ec2 = nil
      super(aws_access_key, aws_secret_key, region, node)
      begin
        @ec2 = Aws::EC2::Client.new(credentials: @credentials,
                                    region:      @region)
      rescue
        Chef::Log.error("failed to create ec2 client")
      end
    end

    # Get public ip of a node
    def get_node_public_ip
      private_ip = ""
      addrs = @node[:network][:interfaces][:eth0][:addresses]
      addrs.each do |addr, val|
        if addr.match(/192.*/)
          private_ip = addr
          break
        end
      end

      resp = @ec2.describe_instances({filters: [{
          name:   'network-interface.addresses.private-ip-address',
          values: [private_ip]}]})
      public_ip = resp.reservations[0].instances[0].public_ip_address
    end
  end
end