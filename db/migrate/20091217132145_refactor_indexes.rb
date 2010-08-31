class RefactorIndexes < ActiveRecord::Migration
  def self.up
    remove_index :labels, :name => :index_labels_on_owner_id_and_language rescue nil
    remove_index :notes, :name => :index_notes_on_owner_id_and_language rescue nil
    remove_index :lexical_variants, :name => :index_lexical_variants_on_owner_id rescue nil
    remove_index :matches, :name => :index_matches_on_concept_id rescue nil
    remove_index :labelings, :name => :index_labelings_on_owner_id_and_target_id rescue nil
    
    add_index :labels, :origin rescue nil
    add_index :labels, :value rescue nil
    add_index :label_relations, [:domain_id, :range_id, :type] rescue nil
    add_index :label_relations, :type rescue nil
    add_index :lexical_variants, [:owner_id, :type] rescue nil
    add_index :lexical_variants, :type rescue nil
    add_index :matches, [:concept_id, :type] rescue nil
    add_index :matches, :type rescue nil
    add_index :notes, [:owner_id, :owner_type, :type] rescue nil
    add_index :notes, :type rescue nil
    add_index :note_annotations, :note_id rescue nil
    add_index :labelings, [:owner_id, :target_id, :type] rescue nil
    add_index :labelings, :type
    add_index :classifiers, :notation rescue nil
  end

  def self.down
  end
end
