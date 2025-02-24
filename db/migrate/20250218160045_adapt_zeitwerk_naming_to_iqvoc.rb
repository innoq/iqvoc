class AdaptZeitwerkNamingToIqvoc < ActiveRecord::Migration[7.1]
  def up
    c = ActiveRecord::Base.connection

    c.tables.collect do |table|
      type_cols = c.columns(table).select { |col| col.name.include? 'type' }.select { |col| col.type == :string }.collect(&:name) # also respect *_type (like owner_type)
      type_cols.each do |col|
        execute "UPDATE #{table} SET #{col} = REGEXP_REPLACE(#{col}, '::SKOS::', '::Skos::', 'g') WHERE #{col} LIKE '%::SKOS::%';"
        execute "UPDATE #{table} SET #{col} = REGEXP_REPLACE(#{col}, '::SKOSXL::', '::Skosxl::', 'g') WHERE #{col} LIKE '%::SKOSXL::%';"
      end
    end
  end

  def down
    c = ActiveRecord::Base.connection

    c.tables.collect do |table|
      type_cols = c.columns(table).select { |col| col.name.include? 'type' }.select { |col| col.type == :string }.collect(&:name) # also respect *_type (like owner_type)
      type_cols.each do |col|
        execute "UPDATE #{table} SET #{col} = REGEXP_REPLACE(#{col}, '::Skos::', '::SKOS::', 'g') WHERE #{col} LIKE '%::Skos::%';"
        execute "UPDATE #{table} SET #{col} = REGEXP_REPLACE(#{col}, '::Skosxl::', '::SKOSXL::', 'g') WHERE #{col} LIKE '%::Skosxl::%';"
      end
    end
  end
end
