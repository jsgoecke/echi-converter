require 'rubygems'
require 'yaml'

#Determine our working directory
$workingdir = File.expand_path File.dirname(__FILE__) 
require $workingdir + '/echi-converter.rb'
include EchiConverter
  

#Open the configuration file
configfile = $workingdir + '/../config/application.yml' 
$config = YAML::load(File.open(configfile))

#Load ActiveRecord Models
if $config["pco_process"] == 'Y'
  require $workingdir + '/database_presence.rb'
else
  require $workingdir + '/database.rb'
end

#Load the configured schema
schemafile = $workingdir + "/../config/" + $config["echi_schema"]
@echi_schema = YAML::load(File.open(schemafile))

#Open the logfile with appropriate output level
initiate_logger
  
#If configured for database insertion, connect to the database
if $config["export_type"] == 'database' || $config["export_type"] == 'both'
  connect_database
end

$init_date = Time.now
@log.info "ECHI-Converter daemon started with these settings:"
@log.info $config.inspect

#Our Main loop
loop do
  #Process the files
  #fetch_ftp_files
  get_ftp_files
  
  #Grab filenames from the to_process directory after an FTP fetch, so if the 
  #system fails it may pick up where it left off
  to_process_dir = $workingdir + "/../files/to_process/"
  
  #Establish where to copy the processed files to
  @processeddirectory = set_directory($workingdir)
  
  Dir.entries(to_process_dir).each do | file |
    if file.slice(0,3) == 'chr' && File.stat("#{to_process_dir}/#{file}").size == 0
      @log.info "Encountered a zero bye chr file: #{file}"
      FileUtils.mv("#{to_process_dir}/#{file}", @processeddirectory)
    else
      if file.slice(0,3) == 'chr'
        if $config["echi_format"] == 'BINARY'
          record_cnt = convert_binary_file file
        elsif $config["echi_format"] == 'ASCII'
          record_cnt = process_ascii file
        end
        @log.info "Processed file #{file} with #{record_cnt.to_s} records"
      end
    end
  end

  if $config["echi_process_dat_files"] == "Y" && $config["pco_process"] == "N"
    process_dat_files
  end
  
  sleep $config["fetch_interval"]

  #Make sure we did not lose our database connection while we slept
  if ActiveRecord::Base.connected? == 'FALSE'
    connect_database
  end
end

#Close the logfile
@log.info "Shutdown..."
@log.close