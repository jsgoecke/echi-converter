class ChangeLogNameSize < ActiveRecord::Migration
  def self.up
    change_column "echi_logs", "filename", :string
  end

  def self.down
    change_column "echi_logs", "filename", :string, :limit => 10
  end
end