class ChangeUmtNoteAnnotationsToDct < ActiveRecord::Migration[4.2]
  def self.up
    execute "UPDATE note_annotations SET namespace = 'dct', predicate = 'creator' WHERE namespace = 'umt' AND predicate = 'editor'"
  end

  def self.down
    execute "UPDATE note_annotations SET namespace = 'umt', predicate = 'editor' WHERE namespace = 'dct' AND predicate = 'creator'"
  end
end
