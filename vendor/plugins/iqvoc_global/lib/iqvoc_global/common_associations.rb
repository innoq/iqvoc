module IqvocGlobal
  module CommonAssociations

    def self.included(base)
      base.class_eval do
       belongs_to :locking_user, :foreign_key => 'locked_by', :class_name => 'User'
      end
    end
  end
end