#A test script that allows one to do a quick database connection test 
#to ensure their database connectivity is configured properly
#require AR
require 'rubygems'
require 'active_record'

# connect to the Database
ActiveRecord:: Base.establish_connection(
  :adapter => "oracle",
  :database => "192.168.10.3/orapr1",
  :username => "myname",
  :password => "mypass"
)

#define a simple model
class EchiRecord < ActiveRecord::Base
  set_table_name "PCO_ECHIRECORD" # comment out if not using oracle
end

begin
  record=EchiRecord.find(:first)
  puts record.inspect
rescue => err
  puts err
end