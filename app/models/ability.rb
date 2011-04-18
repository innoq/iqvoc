# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Ability
  include CanCan::Ability

  @@if_published = lambda { |o| o.published? }

  def initialize(user = nil)

    can :read, Collection::Base

    if user.nil?
      can :read, [Concept::Base, Label::Base], &@@if_published
    end
      
    if user && user.owns_role?(:reader)
      can :read, [Concept::Base, Label::Base], &@@if_published

      can :use, :dashboard
    end
      
    if user && (user.owns_role?(:editor) || user.owns_role?(:publisher) || user.owns_role?(:administrator))
      can :read, [Concept::Base, Label::Base]

      can :use, :dashboard

      can :manage, Collection::Base
      
      can :create, [Concept::Base, Label::Base]
      can [:update, :destroy, :unlock], [Concept::Base, Label::Base], :locked_by => user.id, :published_at => nil
      can :lock, [Concept::Base, Label::Base], :locked_by => nil, :published_at => nil
      
      can :check_consistency, [Concept::Base, Label::Base], :published_at => nil
      can :send_to_review, [Concept::Base, Label::Base], :published_at => nil

      can :branch, [Concept::Base, Label::Base], &@@if_published
    end
    
    if user && (user.owns_role?(:publisher) || user.owns_role?(:administrator))
      can :merge, [Concept::Base, Label::Base], :published_at => nil
    end
    
    if user && user.owns_role?(:administrator)
      can [:update, :destroy, :unlock], [Concept::Base, Label::Base], :published_at => nil # Mustn't be locked by myself

      can :manage, User

      can :full_export, Concept::Base
    end
    
  end
end
