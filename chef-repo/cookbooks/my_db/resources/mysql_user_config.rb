resource_name :mysql_user_config

property :allowed_host, String, default: '%'

load_current_value do
  # some Ruby for loading the current state of the resource
end

action :match do
  password = node['mysql']['root_pwd']
  
  ruby_block "something" do
    block do
      node['mysql']['change_host'] = exec("echo \"SELECT count(*) from mysql.user where host='#{allowed_host}';\" | " \
                                          "mysql -h 127.0.0.1 -u root --password=\"#{password}\" | grep -v count")  
    end
    action :run
    notifies :run, 'ruby_block[sql_query]', :immediately
  end
  
  ruby_block 'sql_query' do
    block do
      if node['mysql']['change_host'] != "1"
        exec("GRANT ALL PRIVILEGES ON *.* TO root@'#{allowed_host}' IDENTIFIED BY '#{password}' WITH GRANT OPTION;")        
      end
    end
    action :nothing    
  end  
end