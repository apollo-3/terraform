require 'mysql2'
module BBnetes
  class MySQL
    def initialize node
       @host     = node['mysql']['host']
       @port     = node['mysql']['port']
       @user     = node['mysql']['user']
       @password = node['mysql']['root_pwd']
       @client   = init_connection
    end

    def init_connection
      @client = Mysql2::Client.new(:host     => @host,
                                   :port     => @port,
                                   :username => @user,
                                   :password => @password)
    end

    public
    def run_query query
      @client.query(query)
    end
  end
end