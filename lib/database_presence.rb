class EchiRecord < ActiveRecord::Base
  set_table_name "PCO_ECHIRECORD"
  set_sequence_name "PCO_ECHIRECORDSEQ"
end

class EchiLog < ActiveRecord::Base
  set_table_name "PCO_ECHILOG"
  set_sequence_name "PCO_ECHILOGSEQ"
end
