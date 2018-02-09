require 'mysql2'
module BBnetes
  class MySQL
    def initialize node
       @host     = '127.0.0.1'
       @port     = node['mysql']['port']
       @user     = node['mysql']['user']
       @password = node['mysql']['pass']
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