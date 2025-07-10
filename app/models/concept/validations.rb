module Concept
  module Validations
    extend ActiveSupport::Concern

    included do
      validates :origin, presence: true, on: :update

      validate :pref_label_in_primary_thesaurus_language
      validate :unique_pref_label_language
      validate :exclusive_top_term
      validate :rooted_top_terms
      validate :valid_rank_for_ranked_relations
      validate :unique_pref_labels
      validate :exclusive_pref_and_alt_labels_per_concept
      validate :exclusive_hidden_labels_per_concept
      validate :unique_alt_labels
      validate :exclusive_broader_and_narrower_concepts
      validate :no_self_reference_concept_relation
    end

    # top term and broader relations are mutually exclusive
    def exclusive_top_term
      if validatable_for_publishing?
        if top_term? && broader_relations.any?
          errors.add :base, I18n.t('txt.models.concept.top_term_exclusive_error')
        end
      end
    end

    # top terms must never be used as descendants (narrower relation targets)
    # NB: for top terms themselves, this is covered by `ensure_exclusive_top_term`
    def rooted_top_terms
      if validatable_for_publishing?
        if narrower_relations.includes(:target). # XXX: inefficient?
            select { |rel| rel.target && rel.target.top_term? }.any?
          errors.add :base, I18n.t('txt.models.concept.top_term_rooted_error')
        end
      end
    end

    def pref_label_in_primary_thesaurus_language
      if validatable_for_publishing?
        labels = pref_labels.select{ |l| l.published? }
        if labels.none?
          errors.add :base, I18n.t('txt.models.concept.no_pref_label_error')
        elsif not labels.map(&:language).map(&:to_s).include?(Iqvoc::Concept.pref_labeling_languages.first.to_s)
          errors.add :base, I18n.t('txt.models.concept.main_pref_label_language_missing_error')
        end
      end
    end

    def unique_pref_label_language
      # We have many sources a prefLabel can be defined in
      pls = pref_labelings.map(&:target) +
        send(Iqvoc::Concept.pref_labeling_class_name.to_relation_name).map(&:target) +
        labelings.select{ |l| l.is_a?(Iqvoc::Concept.pref_labeling_class) }.map(&:target)
      languages = {}
      pls.compact.each do |pref_label|
        lang = pref_label.language.to_s
        origin = (pref_label.origin || pref_label.id || pref_label.value).to_s
        if (languages.keys.include?(lang) && languages[lang] != origin)
          # there are at least two pref labels for one specific language
          errors.add :pref_labelings, I18n.t('txt.models.concept.pref_labels_with_same_languages_error')
          break
        end
        languages[lang] = origin
      end
    end

    def unique_pref_labels
      if validatable_for_publishing?
        # checks if any other concept already owns the chosen pref labels
        conflicting_pref_labels = pref_labels.select do |l|
          Iqvoc::Concept.base_class.joins(:pref_labels).where(labels: { value: l.value, language: l.language }).where('labelings.owner_id != ?', id).where('concepts.origin != ?', origin).any?
        end

        if conflicting_pref_labels.any?
          if conflicting_pref_labels.one?
            errors.add :base,
              I18n.t('txt.models.concept.pref_label_not_unique',
                label: conflicting_pref_labels.last.value)
          else
            errors.add :base,
              I18n.t('txt.models.concept.pref_labels_not_unique',
                label: conflicting_pref_labels.map(&:value).join(', '))
          end
        end
      end
    end

    def exclusive_pref_and_alt_labels_per_concept
      if validatable_for_publishing?
        alt_labels = alt_labelings.collect { |l| l.target }

        pref_labels.each do |pref_label|
          if alt_labels.include? pref_label
              errors.add :base,
                I18n.t('txt.models.concept.pref_label_defined_in_alt_labels',
                  label: pref_label.value)
          end
        end
      end
    end

    def exclusive_hidden_labels_per_concept
      if self.validatable_for_publishing?
        relevant_labels = self.labelings.reject { |lbl| lbl.is_a?(Iqvoc::Concept.hidden_labeling_class) }.collect(&:target)

        self.hidden_labels.each do |hidden_label|
          if relevant_labels.include? hidden_label
            errors.add :base, I18n.t('txt.models.concept.hidden_label_defined_in_other_labels', label: hidden_label.value)
          end
        end

      end
    end

    def unique_alt_labels
      if validatable_for_publishing?
        alt_labels = alt_labelings.collect { |l| l.target }
        duplicate = alt_labels.detect { |e| alt_labels.select {|al| al.published? }.count(e) > 1 }

        if duplicate
          errors.add :base,
              I18n.t('txt.models.concept.alt_labels_not_unique',
                label: duplicate.value)
        end
      end
    end

    def valid_rank_for_ranked_relations
      if validatable_for_publishing?
        relations.each do |relation|
          if relation.class.rankable? && !(0..100).include?(relation.rank)
            errors.add :base, I18n.t('txt.models.concept.invalid_rank_for_ranked_relations',
              relation: relation.class.model_name.human.downcase,
              relation_target_label: relation.target.pref_label.to_s)
          end
        end
      end
    end

    def exclusive_broader_and_narrower_concepts
      if validatable_for_publishing?
        relations_union = broader_relations.map { |b| b.target } & narrower_relations.map { |n| n.target }

        if relations_union.any?
          errors.add :base, I18n.t('txt.models.concept.no_narrower_and_broader_relations', concepts: relations_union.each { |u| u.narrower_relations.map{ |r| r.owner.pref_labels.first } }.flatten.join(', '))
        end
      end
    end

    def no_self_reference_concept_relation
      if validatable_for_publishing?
        # check all related concepts (e.g. skos:broader, skos:narrower, skos:related)
        if related_concepts.include?(self)
          errors.add :base, I18n.t('txt.models.concept.no_self_reference')
        end
      end
    end
  end
end
