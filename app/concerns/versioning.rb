# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

module Versioning
  extend ActiveSupport::Concern

  included do
    belongs_to :published_version, foreign_key: 'published_version_id', class_name: name
    belongs_to :locking_user, foreign_key: 'locked_by', class_name: 'User'

    after_initialize do
      disable_validations_for_publishing
    end
  end

  module ClassMethods
    def by_origin(origin)
       where(origin: origin)
     end

     def published
       where(arel_table[:published_at].not_eq(nil))
     end

     def unpublished
       where(published_at: nil)
     end

     # The following method returns all objects which should be selectable by the editor
     def editor_selectable
       where(
         arel_table[:published_at].not_eq(nil).or( # == published (is there a way to OR combine two scopes? `published OR where(...)`)
           arel_table[:published_at].eq(nil).and(arel_table[:published_version_id].eq(nil)) # this are all unpublished with no published version
         )
       )
     end

     def in_edit_mode
       where(arel_table[:locked_by].not_eq(nil))
     end

     def unpublished_or_follow_up
       where(
         arel_table[:published_at].eq(nil).or(
           arel_table[:follow_up].not_eq(nil)
         )
       )
     end

     def unsynced
       where(rdf_updated_at: nil)
     end

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

  def branch(user)
    new_version = self.dup(include: self.class.includes_to_deep_cloning)
    new_version.lock_by_user(user.id)
    new_version.increment(:rev)
    new_version.published_version_id = self.id
    new_version.unpublish
    new_version.send(:"#{Iqvoc.change_note_class_name.to_relation_name}").build(
      language: I18n.locale.to_s,
      annotations_attributes: [
        { namespace: "dct", predicate: "creator", value: user.name },
        { namespace: "dct", predicate: "modified", value: DateTime.now.to_s }
      ])
    new_version
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

  def with_validations_for_publishing
    enable_validations_for_publishing
    status = yield
    disable_validations_for_publishing

    return status
  end

  def enable_validations_for_publishing
    @_run_validations_for_publishing = true
  end

  def disable_validations_for_publishing
    @_run_validations_for_publishing = false
  end

  def validatable_for_publishing?
    @_run_validations_for_publishing
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

  def publish!
    with_validations_for_publishing do
      publish
      save!
    end
  end

  def publishable?
    with_validations_for_publishing do
      valid?
    end
  end
end
