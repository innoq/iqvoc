class AddLanguageToNoteAnnotations < ActiveRecord::Migration
  def change
    add_column :note_annotations, :language, :string
  end
end
