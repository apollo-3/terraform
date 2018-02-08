module BBnetes
  module Helper
    # Set Database address
    def self.set_db_ip_attribute(node)
      db = Chef::Search::Query.new.search(:node, 'role:db').first
      addrs = db[0][:network][:interfaces][:eth0][:addresses]
      addrs.each do |addr, val|
        if addr.match(/192.*/)
          node.default['tomcat']['java_opts']['host'] = addr
          break
        end
      end
    end

    # Set database password from DataBag
    def self.set_db_password_attribute(node)
      dbg = Chef::Search::Query.new.search(:db, 'id:mysql').first.first
      node.default['tomcat']['java_opts']['pass'] = dbg['password']
      # Get the rest of Database parameters from environment file
      node.default['tomcat']['java_opts']['user'] = node['mysql']['user']
      node.default['tomcat']['java_opts']['port'] = node['mysql']['port']
    end

    # Get the rest of Database parameters from environment file
    def self.build_java_opts_string(node)
      java_opts = ""
      node['tomcat']['java_opts'].each do |opt, val|
        java_opts += "-D#{opt}=#{val} "
      end
      java_opts
    end
  end
end