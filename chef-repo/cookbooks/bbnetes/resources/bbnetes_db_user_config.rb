resource_name :bbnetes_db_user_config

property :allowed_host, String, default: '%'

load_current_value do |desired|
  db = BBnetes::MySQL.new(node)
  result = db.run_query("SELECT host FROM mysql.user " \
                        "WHERE host=\"#{desired.allowed_host}\";")
  current_allowed_host = result.any? ? desired.allowed_host : 'NA'
  allowed_host current_allowed_host
end

action :match do
  converge_if_changed :allowed_host do
    user     = node['mysql']['user']
    password = node['mysql']['pass']

    db = BBnetes::MySQL.new(node)
    db.run_query("GRANT ALL PRIVILEGES ON *.* TO " \
                 "#{user}@\"#{new_resource.allowed_host}\" IDENTIFIED BY " \
                 "\"#{password}\" WITH GRANT OPTION;")
  end
end

action_class do
  include BBnetes
end