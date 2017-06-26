class AddNoteAnnotationsIndex < ActiveRecord::Migration
  def change
    add_index :note_annotations, :value
  end
end
