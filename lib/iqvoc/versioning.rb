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

module Iqvoc
  module Versioning

    extend ActiveSupport::Concern

    included do

      # ********* Relations

      belongs_to :published_version, :foreign_key => 'published_version_id', :class_name => name

      belongs_to :locking_user, :foreign_key => 'locked_by', :class_name => 'User'

      # ********* Scopes

      scope :by_origin, lambda { |origin|
        where(:origin => origin)
      }

      scope :published, lambda {
        where(arel_table[:published_at].not_eq(nil))
      }
      scope :unpublished,  lambda {
        where(:published_at => nil)
      }
      # The following scope returns all objects which should be selectable by the editor
      scope :editor_selectable, lambda {
        where(
          arel_table[:published_at].not_eq(nil).or( # == published (is there a way to OR comibne two scopes? [published OROPERATOR where(...)])
            arel_table[:published_at].eq(nil).and(arel_table[:published_version_id].eq(nil)) # this are all unpublished with no published version
          )
        )
      }

      scope :in_edit_mode, lambda {
        where(arel_table[:locked_by].not_eq(nil))
      }

      scope :unpublished_or_follow_up, lambda {
        where(
          arel_table[:published_at].eq(nil).or(
            arel_table[:follow_up].not_eq(nil)
          )
        )
      }

      scope :unsynced, lambda {
        where(:rdf_updated_at => nil)
      }

    end

    # ********* Methods

    def branch(user)
      new_version = self.dup(:include => self.class.includes_to_deep_cloning)
      new_version.lock_by_user(user.id)
      new_version.increment(:rev)
      new_version.published_version_id = self.id
      new_version.unpublish
      new_version.send(:"#{Iqvoc.change_note_class_name.to_relation_name}").build(
        :language => I18n.locale.to_s,
        :annotations_attributes => [
          { :namespace => "dct", :predicate => "creator", :value => user.name },
          { :namespace => "dct", :predicate => "modified", :value => DateTime.now.to_s }
        ])
      new_version
    end

    def publish
      write_attribute(:published_at, Time.now)
      write_attribute(:to_review, nil)
      write_attribute(:published_version_id, nil)
    end

    def unpublish
      write_attribute(:published_at, nil)
    end

    def published?
      read_attribute(:published_at).present?
    end

    # Editor selectable if published or no published version exists (before
    # first publication)
    def editor_selectable?
      published? || read_attribute(:published_version_id).blank?
    end

    def lock_by_user(user_id)
      write_attribute(:locked_by, user_id)
    end

    def locked?
      locked_by?
    end

    def state
      if published?
        I18n.t("txt.common.state.published")
      elsif !published? && in_review?
        I18n.t("txt.common.state.in_review")
      elsif !published? && !in_review?
        I18n.t("txt.common.state.checked_out")
      end
    end

    def unlock
      write_attribute(:locked_by, nil)
    end

    def in_review?
      read_attribute(:to_review).present?
    end

    def to_review
      write_attribute(:to_review, true)
    end

    module ClassMethods

      def include_to_deep_cloning(*association_names)
        (@@include_to_deep_cloning ||= {})[self] ||= []
        association_names.each do |association_name|
          @@include_to_deep_cloning[self] << association_name
        end
      end

      def includes_to_deep_cloning
        (@@include_to_deep_cloning ||= {})[self] ||= []
        (@@include_to_deep_cloning.keys & self.ancestors).map{|c| @@include_to_deep_cloning[c]}.flatten.compact
      end

    end

  end
end
