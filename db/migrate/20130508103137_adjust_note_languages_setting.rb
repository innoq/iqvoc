class AdjustNoteLanguagesSetting < ActiveRecord::Migration

  class ConfigSettings < ActiveRecord::Base
    self.table_name = "configuration_settings"
  end

  def up
    record = ConfigSettings.where("key" => "note_languages").first
    record.update_attribute("key", "languages.notes") if record
  end

  def down
    record = ConfigSettings.where("key" => "languages.notes").first
    record.update_attribute("key", "note_languages") if record
  end

end
