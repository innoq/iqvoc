class SeparateNoteAnnotationPredicates < ActiveRecord::Migration
  def self.up
    rename_column :note_annotations, :identifier, :predicate
    add_column :note_annotations, :namespace, :string, :limit => 50
    Note::Annotated::Base.all.each do |annotation|
      old_identifier = annotation.predicate
      namespace, predicate = old_identifier.split(":", 2)
      annotation.predicate = predicate
      annotation.namespace = namespace
      annotation.save!
    end
  end

  def self.down
    Note::Annotated::Base.all.each do |annotation|
      identifier = [annotation.namespace, annotation.predicate].join(":")
      annotation.predicate = identifier
      annotation.save!
    end
    rename_column :note_annotations, :predicate, :identifier
    remove_column :note_annotations, :namespace
  end
end
