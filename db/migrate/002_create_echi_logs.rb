class CreateEchiLogs < ActiveRecord::Migration
  def self.up
    create_table "echi_logs", :force => true do |t|
      t.column "filename", :string, :limit => 10
      t.column "filenumber", :integer
      t.column "version", :integer
      t.column "records", :integer
      t.column "processed_at", :datetime
    end
  end

  def self.down
    drop_table "echi_logs"
  end
end