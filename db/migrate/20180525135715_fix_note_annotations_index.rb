class FixNoteAnnotationsIndex < ActiveRecord::Migration
  def change
    remove_index :note_annotations, column: :value if index_exists? :note_annotations, :value
    add_index :note_annotations, :value
  end
end
