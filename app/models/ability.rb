class Ability
  include CanCan::Ability

  @@if_published = lambda { |o| o.published? }

  def initialize(user = nil)
    
    if user.nil?
      can :read, [Concept::Base, Label::Base], &@@if_published
    end
      
    if user && user.owns_role?(:reader)
      can :read, [Concept::Base, Label::Base], &@@if_published

      can :use, :dashboard
    end
      
    if user && user.owns_role?(:editor)
      can :read, [Concept::Base, Label::Base]

      can :use, :dashboard
      
      can :create, [Concept::Base, Label::Base]
      can [:update, :destroy, :unlock], [Concept::Base, Label::Base], :locked_by => user.id, :published_at => nil
      can :lock, [Concept::Base, Label::Base], :locked_by => nil, :published_at => nil

      can :branch, [Concept::Base, Label::Base], &@@if_published
    end
    
    if user && user.owns_role?(:publisher)
      can :read, [Concept::Base, Label::Base]

      can :use, :dashboard

      can :create, [Concept::Base, Label::Base]
      can [:update, :destroy, :unlock], [Concept::Base, Label::Base], :locked_by => user.id, :published_at => nil
      can :lock, [Concept::Base, Label::Base], :locked_by => nil, :published_at => nil

      can :branch, [Concept::Base, Label::Base], &@@if_published
      can :merge, [Concept::Base, Label::Base], :published_at => nil
    end
    
    if user && user.owns_role?(:administrator)
      can :read, [Concept::Base, Label::Base]

      can :manage, User
      can :use, :dashboard
      
      can :create, [Concept::Base, Label::Base]
      can [:update, :destroy, :unlock], [Concept::Base, Label::Base], :published_at => nil
      can :lock, [Concept::Base, Label::Base], :locked_by => nil, :published_at => nil

      can :branch, [Concept::Base, Label::Base], &@@if_published
      can :merge, [Concept::Base, Label::Base], :published_at => nil
    end
    
  end
end