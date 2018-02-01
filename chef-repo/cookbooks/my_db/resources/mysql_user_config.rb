resource_name :mysql_user_config

property :allowed_host, String, default: '%'

load_current_value do
  # some Ruby for loading the current state of the resource
end

action :match do
  password = node['mysql']['root_pwd']
  allowed_host = new_resource.allowed_host

  execute "something" do
    command "echo \"GRANT ALL PRIVILEGES ON *.* TO root@'#{allowed_host}' IDENTIFIED BY " \
            "'#{password}' WITH GRANT OPTION;\" | " \
            "mysql -h 127.0.0.1 -u root --password=\"#{password}\""
    action :run
    not_if "echo \"SELECT count(*) from mysql.user where host='#{allowed_host}';\" | " \
            "mysql -h 127.0.0.1 -u root --password=\"#{password}\" | grep -v count | grep 1"
  end
end