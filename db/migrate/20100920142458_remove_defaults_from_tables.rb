class RemoveDefaultsFromTables < ActiveRecord::Migration
  def self.up
    change_column_default :concepts, :type, nil
    change_column_default :concept_relations, :type, nil
    change_column_default :labels, :language, nil
    change_column_default :notes, :language, nil
  end

  def self.down
  end
end
