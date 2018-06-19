class AddNoteAnnotationsIndex < ActiveRecord::Migration
  def change
    # causes https://github.com/innoq/iqvoc/issues/389
    # outcommented as fix because we either could have had a custom index name
    # or migrated to utf8mb4 to create the index afterwards
    # we have chosen utf8mb4 since that also fixes utf8 encoding problems in mysql and avoids customized solutions per database
    # add_index :note_annotations, :value
  end
end
