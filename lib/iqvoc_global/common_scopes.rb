module IqvocGlobal
  module CommonScopes

    def self.included(base)
      base.class_eval do
        
        scope :current_version, lambda { |origin| {
          :conditions => ["(origin = :origin) AND (rev = (select min(rev) from #{self.table_name} WHERE origin = :origin))", 
            { :origin => origin }] }
        }
        
        scope :by_origin, lambda {|arg|
          { :conditions => ["origin = ?", arg] }
        }
        
        scope :for_dashboard,
          :conditions => ["(published_at IS NULL) OR (follow_up IS NOT NULL)"]

        scope :initial_version, lambda { |origin| {
          :conditions => ["(origin = :origin) AND (rev = 1) AND (published_at IS NULL)",
            { :origin => origin }] }
        }

        scope :new_version, lambda { |origin| {
          :conditions => ["(origin = :origin) AND (rev > (select min(rev) from #{self.table_name} WHERE origin = :origin))",
            { :origin => origin }] }
        }
        
        scope :published, :conditions => "#{self.table_name}.published_at IS NOT NULL"
        scope :unpublished, :conditions => "#{self.table_name}.published_at IS NULL"
        
        scope :unsynced, :conditions => "#{self.table_name}.rdf_updated_at IS NULL"
          
      end
    end
  end
end