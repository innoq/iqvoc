module Concept
  module Validations
    extend ActiveSupport::Concern

    included do
      validates :origin, :presence => true, :on => :update

      validate :distinct_versions, :on => :create
      validate :pref_label_in_primary_thesaurus_language, :on => :update
      validate :unique_pref_label_language
      validate :exclusive_top_term
      validate :rooted_top_terms
      validate :valid_rank_for_ranked_relations
      validate :unique_pref_label
    end

    def distinct_versions
      query = Concept::Base.by_origin(origin)
      existing_total = query.count
      if existing_total >= 2
        errors.add :base, I18n.t("txt.models.concept.version_error")
      elsif existing_total == 1
        unless (query.published.count == 0 and published?) or
               (query.published.count == 1 and not published?)
          errors.add :base, I18n.t("txt.models.concept.version_error")
        end
      end
    end

    # top term and broader relations are mutually exclusive
    def exclusive_top_term
      if @full_validation
        if top_term and broader_relations.any?
          errors.add :base, I18n.t('txt.models.concept.top_term_exclusive_error')
        end
      end
    end

    # top terms must never be used as descendants (narrower relation targets)
    # NB: for top terms themselves, this is covered by `ensure_exclusive_top_term`
    def rooted_top_terms
      if @full_validation
        if self.narrower_relations.map(&:target).compact.any?(&:top_term?)
          errors.add :base, I18n.t('txt.models.concept.top_term_rooted_error')
        end
      end
    end

    def pref_label_in_primary_thesaurus_language
      if @full_validation
        labels = pref_labels.select(&:published?)
        primary_language = Iqvoc::Concept.pref_labeling_languages.first.to_s
        if labels.empty?
          errors.add :base, I18n.t('txt.models.concept.no_pref_label_error')
        elsif not labels.find {|l| l.language.to_s == primary_language }
          errors.add :base, I18n.t('txt.models.concept.main_pref_label_language_missing_error')
        end
      end
    end

    def unique_pref_label_language
      languages = {}
      self.pref_labels.each do |pref_label|
        lang   = pref_label.language.to_s
        origin = (pref_label.origin || pref_label.id || pref_label.value).to_s
        if languages.keys.include?(lang) and languages[lang] != origin
          errors.add :pref_labelings, I18n.t('txt.models.concept.pref_labels_with_same_languages_error')
        end
        languages[lang] = origin
      end
    end

    def unique_pref_label
      if @full_validation
        # checks if there are any existing pref labels with the same
        # language and value
        conflicting_pref_labels = pref_labels.select do |l|
          Labeling::SKOS::PrefLabel.
            joins(:owner, :target).
            where(:labels => { :value => l.value, :language => l.language }).
            where("labelings.owner_id != ?", id).
            where("concepts.origin != ?", origin).
            any?
        end

        if conflicting_pref_labels.any?
          if conflicting_pref_labels.one?
            errors.add :base,
              I18n.t("txt.models.concept.pref_label_not_unique",
                :label => conflicting_pref_labels.last.value)
          else
            errors.add :base,
              I18n.t("txt.models.concept.pref_labels_not_unique",
                :label => conflicting_pref_labels.map(&:value).join(", "))
          end
        end
      end
    end

    def valid_rank_for_ranked_relations
      if @full_validation
        relations.each do |relation|
          if relation.class.rankable? && !(0..100).include?(relation.rank)
            errors.add :base, I18n.t("txt.models.concept.invalid_rank_for_ranked_relations",
              :relation => relation.class.model_name.human.downcase,
              :relation_target_label => relation.target.pref_label.to_s)
          end
        end
      end
    end

  end
end
