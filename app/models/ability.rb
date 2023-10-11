class Ability
  include CanCan::Ability

  @@if_published = lambda { |o| o.published? }

  def initialize(user = nil)
    can :read, Iqvoc::Concept.root_class.instance
    can :read, [::Concept::Base, ::Collection::Base, ::Label::Base], &@@if_published

    # static pages
    can :read, :help
    can :read, :version

    if user # Every logged in user ...
      can :use, :dashboard
      can :destroy, UserSession
      can :update, User, id: user.id # users can update their profile

      if user.owns_role?(:reader)
        can :read, [::Concept::Base, ::Collection::Base, ::Label::Base]
      end

      if user.owns_role?(:editor) || user.owns_role?(:publisher) || user.owns_role?(:administrator) # Editors and above ...
        can :read, [::Concept::Base, ::Collection::Base, ::Label::Base]
        can :create, [::Concept::Base, ::Collection::Base, ::Label::Base]
        can [:update, :destroy, :unlock], [::Concept::Base, ::Collection::Base, ::Label::Base], locked_by: user.id, published_at: nil
        can :lock, [::Concept::Base, ::Collection::Base, ::Label::Base], locked_by: nil, published_at: nil
        can :check_consistency, [::Concept::Base, ::Collection::Base, ::Label::Base], published_at: nil
        can :send_to_review, [::Concept::Base, ::Collection::Base, ::Label::Base] do |object|
          !object.in_review? && object.locked_by == user.id
        end
        can :branch, [::Concept::Base, ::Collection::Base, ::Label::Base], &@@if_published
      end

      if user.owns_role?(:match_editor)
        can :read, ::Concept::Base
        can :create, ::Concept::Base
        can [:update, :lock], ::Concept::Base, locked_by: user.id, published_at: nil
        can :lock, ::Concept::Base, locked_by: nil, published_at: nil
        can :branch, ::Concept::Base, &@@if_published
      end

      if user.owns_role?(:publisher) || user.owns_role?(:administrator) # Publishers and above ...
        can :merge, [::Concept::Base, ::Collection::Base, ::Label::Base] do |object|
          !object.published? && (!object.locked? || object.locked_by == user.id)
        end
      end

      if user.owns_role?(:administrator)
        can [:update, :destroy, :unlock], [::Concept::Base, ::Label::Base], published_at: nil # Mustn't be locked by myself

        can :manage, User
        can :manage, Iqvoc.config

        can :full_export, ::Concept::Base
        can :import, ::Concept::Base
        can :export, ::Concept::Base

        can :update, Iqvoc::Concept.root_class.instance

        can :use, :administration

        can :reset, :thesaurus
        can :sync, :triplestore

        can :see, :exception
        can :profile, :system
      end
    else # no user
      can :create, UserSession
    end
  end
end
