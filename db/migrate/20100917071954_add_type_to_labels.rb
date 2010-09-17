class AddTypeToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :type, :string

    Label::Base.update_all(:type => "Label::SKOSXL::Base")

  end

  def self.down
    remove_column :labels, :type
  end
end
