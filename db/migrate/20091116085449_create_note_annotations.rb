class CreateNoteAnnotations < ActiveRecord::Migration
  def self.up
    create_table :note_annotations do |t|
      t.references :note
      t.string :type, :limit => 50
      t.string :value, :limit => 1024

      t.timestamps
    end
  end

  def self.down
    drop_table :note_annotations
  end
end
