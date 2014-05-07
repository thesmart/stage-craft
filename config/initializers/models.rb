require 'data_mapper'
require 'dm-timestamps'

# Log to stdout
DataMapper::Logger.new($logger_dm, :debug)
# Force raising errors
DataMapper::Model.raise_on_save_failure = true
# default lengths
DataMapper::Property::String.length(255)
DataMapper::Property::Text.length(65535)

if $settings.production?
  # A MySql connection
  DataMapper.setup(:default, "mysql://#{$settings.mysql_user}:#{$settings.mysql_password}@#{$settings.mysql_hostname}/stage_craft")
else
  # A Sqlite3 connection
  db_file_path = "#{$settings.root}/tmp/#{$settings.environment}.sqllite.db"
  db_folder_path = File.dirname(db_file_path)
  Dir.mkdir(db_folder_path) unless Dir.exist?(db_folder_path)
  File.delete(db_file_path) if $settings.test? and File.exist?(db_file_path)
  DataMapper.setup(:default, "sqlite://#{db_file_path}")
end

# Require all models
Dir["#{$settings.root}/lib/models/*.rb"].each {|file| require file }
DataMapper.finalize
DataMapper.auto_upgrade!