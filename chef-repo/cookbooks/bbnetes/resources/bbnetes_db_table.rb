resource_name :bbnetes_db_table

property :table, String, default: 'test'

default_action :create

load_current_value do |desired|
  db = BBnetes::MySQL.new(node)
  result = db.run_query("SHOW TABLES IN mysql WHERE tables_in_mysql=\"#{desired.table}\";")
  current_table = result.any? ? desired.table : 'NA'
  table current_table
end

action :create do
  converge_if_changed :table do
    db = BBnetes::MySQL.new(node)
    db.run_query("CREATE TABLE mysql.#{new_resource.table} (name VARCHAR(100));")
  end
end

action :delete do
  if current_resource.table == new_resource.table
    db = BBnetes::MySQL.new(node)
    db.run_query("DROP TABLE mysql.#{new_resource.table};")
    new_resource.updated_by_last_action(true)
  end
end

action_class do
  include BBnetes
end