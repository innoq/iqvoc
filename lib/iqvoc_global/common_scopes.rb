module IqvocGlobal
  module CommonScopes

    def self.included(base)
      base.class_eval do
        
        scope :by_origin, lambda { |origin|
         where(:origin => origin) 
        }

        scope :published, where(arel_table[:published_at].not_eq(nil))
        scope :unpublished, where(:published_at => nil)
        
        scope :for_dashboard, unpublished.where(:follow_up => nil)

        scope :unsynced, where(:rdf_updated_at => nil)
          
      end
    end
  end
end