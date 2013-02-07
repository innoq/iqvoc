module Concept
  module LabelingSubtypeExtensions
    def for_class(labeling_class)
      if proxy_association.target.empty?
        proxy_association.owner.labelings.to_a
      end
      proxy_association.target.select{|assoc| assoc.is_a? labeling_class}
    end

    def available_names
      ['skos_pref'] + Iqvoc::Concept.labeling_class_names.map(&:relation_name)
    end

    protected

    base_labelings = {'skos_pref' => Iqvoc::Concept.pref_labeling_class_name.constantize}
    labelings = Iqvoc::Concept.further_labeling_class_names.inject(base_labelings) do |hash, name|
      klass = name.first.constantize
      hash[klass.relation_name] = klass
      hash
    end

    labelings.each do |relation_name, labeling_class|
      define_method relation_name do
        for_class labeling_class
      end
    end

  end
end
