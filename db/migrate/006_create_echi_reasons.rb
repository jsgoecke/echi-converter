class CreateEchiReasons < ActiveRecord::Migration
  def self.up
    #We create the table from the one defined in the application.yml file
    create_table "echi_reasons", :force => true do |t|
      @@echi_schema["echi_reasons"].each do | field |
        case field["type"]
        when 'int'
          if ActiveRecord::Base.connection.adapter_name == 'Oracle'
            case field["length"]
            when 4
              oracle_precision = 10
            when 2
              oracle_precision = 5
            when 1
              oracle_precision = 3
            end
            t.column field["name"], :integer, :limit => oracle_precision, :precision => oracle_precision, :scale => 0
          else
            t.column field["name"], :integer, :limit => field["length"], :precision => field["length"], :scale => 0
          end
        when 'str'
          t.column field["name"], :string, :limit => field["length"]
        when 'datetime'
          t.column field["name"], :datetime
        when 'bool'
          t.column field["name"], :string, :limit => 1
        when 'boolint'
          t.column field["name"], :string, :limit => 1
        end
      end
    end
  end

  def self.down
    drop_table "echi_reasons"
  end
end