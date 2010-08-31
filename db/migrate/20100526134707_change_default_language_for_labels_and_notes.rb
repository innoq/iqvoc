class ChangeDefaultLanguageForLabelsAndNotes < ActiveRecord::Migration
  def self.up
    change_column_default :labels, :language, "de"
    change_column_default :notes, :language, "de"
  end

  def self.down
    change_column_default :labels, :language, "en"
    change_column_default :notes, :language, "en"
  end
end
