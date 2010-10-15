module IqvocGlobal
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
        where(arel_table[:locked_by].eq(nil).complement)
      }

      scope :for_dashboard, lambda {
        where(
          arel_table[:published_at].eq(nil).or(
            arel_table[:follow_up].not_eq(nil)
          )
        )
      }

      scope :unsynced, where(:rdf_updated_at => nil)

      # ********* Methods

      def branch(user)
        new_version = self.clone(:include => self.class.includes_to_deep_cloning)
        new_version.lock_by_user!(user.id)
        new_version.increment!(:rev)
        new_version.unpublish!
        if new_version.class.reflections.symbolize_keys.keys.include?(:note_umt_change_notes)
          new_version.note_umt_change_notes.build(:language => I18n.locale.to_s, # FIXME: Hardcoded relation and language!!
            :annotations_attributes => [
              { :identifier => "umt:editor", :value => user.try(:name) },
              { :identifier => "dct:modified", :value => DateTime.now.to_s }
            ])
        end
        new_version
      end

      def publish!
        write_attribute(:published_at, Time.now)
        write_attribute(:to_review, nil)
        write_attribute(:published_version_id, nil)
      end

      def unpublish!
        write_attribute(:published_at, nil)
      end

      def published?
        read_attribute(:published_at).present?
      end

      def lock_by_user!(user_id)
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

      def unlock!
        write_attribute(:locked_by, nil)
      end

      def in_review?
        read_attribute(:to_review).present?
      end

      def to_review!
        write_attribute(:to_review, true)
      end

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
