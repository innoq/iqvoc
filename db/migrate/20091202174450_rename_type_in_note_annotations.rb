class RenameTypeInNoteAnnotations < ActiveRecord::Migration
  def self.up
    rename_column :note_annotations, :type, :identifier
  end

  def self.down
    rename_column :note_annotations, :identifier, :type
  end
end
