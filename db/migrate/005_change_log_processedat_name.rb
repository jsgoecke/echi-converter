class ChangeLogProcessedatName < ActiveRecord::Migration
  def self.up
    rename_column "echi_logs", "processed_at", "processedat"
  end

  def self.down
    rename_column "echi_logs", "processedat", "processed_at"
  end
end