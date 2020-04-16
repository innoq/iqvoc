class SeparateNoteAnnotationPredicates < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :note_annotations, :identifier, :predicate
    add_column :note_annotations, :namespace, :string, limit: 50

    annotations = select_rows('SELECT id, predicate FROM note_annotations')

    annotations.each do |annotation|
      namespace, predicate = annotation[1].split(':', 2)
      execute "UPDATE note_annotations SET namespace = '#{namespace}', predicate = '#{predicate}' WHERE id = #{annotation[0]}"
    end
  end

  def self.down
    annotations = select_rows('SELECT id, predicate, namespace FROM note_annotations')

    annotations.each do |annotation|
      identifier = [annotation[2], annotation[1]].join(':')
      execute "UPDATE note_annotations SET predicate = '#{identifier}' WHERE id = #{annotation[0]}"
    end

    rename_column :note_annotations, :predicate, :identifier
    remove_column :note_annotations, :namespace
  end
end
