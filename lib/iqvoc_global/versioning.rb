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

      scope :for_dashboard, lambda {
        where(
          arel_table[:published_at].eq(nil).or(
            arel_table[:follow_up].not_eq(nil)
          )
        )
      }

      scope :unsynced, where(:rdf_updated_at => nil)

      # ********* Methods

      def after_branch
        if branched?
          umt_change_notes.create!(:language => language,
            :note_annotations_attributes => [
              { :identifier => "umt:editor", :value => locking_user.try(:name) },
              { :identifier => "dct:modified", :value => DateTime.now.to_s }
            ])
        end
      end

      def branched?
        rev > 1
      end

      def publish!
        write_attribute(:published_at, Time.now)
        write_attribute(:to_review, nil)
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

      def prepare_for_branching(user_id)
        lock_by_user!(user_id)
        increment!(:rev)
        write_attribute(:created_at, Time.now)
        write_attribute(:updated_at, Time.now)
        unpublish!
      end

      def prepare_for_merging
        publish!
        unlock!
      end

    end

  end
end