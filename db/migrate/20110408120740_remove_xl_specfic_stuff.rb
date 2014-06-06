class RemoveXlSpecficStuff < ActiveRecord::Migration

  def self.up
    drop_table 'label_relations'

    remove_column :labels, 'rev'
    remove_column :labels, 'published_version_id'
    remove_column :labels, 'published_at'
    remove_column :labels, 'locked_by'
    remove_column :labels, 'expired_at'
    remove_column :labels, 'follow_up'
    remove_column :labels, 'to_review'
    remove_column :labels, 'rdf_updated_at'
  end

  def self.down
    add_column :labels, 'rev', :integer,  default: 1
    add_column :labels, 'published_version_id', :integer
    add_column :labels, 'published_at', :date
    add_column :labels, 'locked_by', :integer
    add_column :labels, 'expired_at', :date
    add_column :labels, 'follow_up', :date
    add_column :labels, 'to_review', :boolean
    add_column :labels, 'rdf_updated_at', :date

    create_table 'label_relations', force: true do |t|
      t.string   'type'
      t.integer  'domain_id'
      t.integer  'range_id'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'label_relations', ['domain_id', 'range_id', 'type'], name: 'index_label_relations_on_domain_id_and_range_id_and_type'
    add_index 'label_relations', ['type'], name: 'index_label_relations_on_type'

  end

end
