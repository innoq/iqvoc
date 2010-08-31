class Ability
  include CanCan::Ability

  def initialize(user = nil)
    
    if user.nil?
      can :read, [:published_concept, :published_label]
    end
      
    if user && user.owns_role?(:reader)
      can :read, [:published_concept, :published_label]
      can :use, :dashboard
    end
      
    if user && user.owns_role?(:editor)
      can :read, [:published_concept, :published_label]
      can [:read, :write], [:versioned_label, :versioned_concept]
      can :use, :dashboard
      
      can :unlock, Concept, :locked_by => user.id
      can :unlock, Label, :locked_by => user.id
      
      can :continue_editing, Concept, :locked_by => user.id
      can :continue_editing, Label, :locked_by => user.id
    end
    
    if user && user.owns_role?(:publisher)
      can :read, [:published_concept, :published_label]
      can [:read, :write, :publish], [:versioned_label, :versioned_concept]
      can :use, :dashboard
      
      can :unlock, Concept
      can :unlock, Label
      
      can :continue_editing, Concept, :locked_by => user.id
      can :continue_editing, Label, :locked_by => user.id
    end
    
    if user && user.owns_role?(:administrator)
      can :read, [:published_concept, :published_label]
      can [:read, :write, :publish], [:versioned_label, :versioned_concept]
      can :manage, User
      can :use, :dashboard
      
      can :unlock, Concept
      can :unlock, Label
      
      can :continue_editing, Concept, :locked_by => user.id
      can :continue_editing, Label, :locked_by => user.id
    end
    
  end
end