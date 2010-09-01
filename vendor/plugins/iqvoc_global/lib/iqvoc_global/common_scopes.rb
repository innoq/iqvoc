module IqvocGlobal
  module CommonScopes

    def self.included(base)
      base.class_eval do
        
        named_scope :current_version, lambda { |origin| {
          :conditions => ["(origin = :origin) AND (rev = (select min(rev) from #{self.table_name} WHERE origin = :origin))", 
            { :origin => origin }] }
        }
        
        named_scope :by_origin, lambda {|arg|
          { :conditions => ["origin = ?", arg] }
        }
        
        named_scope :for_dashboard,
          :conditions => ["(published_at IS NULL) OR (follow_up IS NOT NULL)"]

        named_scope :initial_version, lambda { |origin| {
          :conditions => ["(origin = :origin) AND (rev = 1) AND (published_at IS NULL)",
            { :origin => origin }] }
        }

        named_scope :new_version, lambda { |origin| {
          :conditions => ["(origin = :origin) AND (rev > (select min(rev) from #{self.table_name} WHERE origin = :origin))",
            { :origin => origin }] }
        }
        
        named_scope :published, :conditions => "#{self.name.tableize}.published_at IS NOT NULL"
        named_scope :unpublished, :conditions => "#{self.name.tableize}.published_at IS NULL"
        
        named_scope :unsynced, :conditions => "#{self.name.tableize}.rdf_updated_at IS NULL"
          
      end
    end
  end
end