class AddLanguageToNoteAnnotations < ActiveRecord::Migration[4.2]
  def change
    add_column :note_annotations, :language, :string
  end
end
