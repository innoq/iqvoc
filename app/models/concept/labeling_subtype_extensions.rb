module Concept
  module LabelingSubtypeExtensions
    def for_class(labeling_class)
      if proxy_association.target.empty?
        proxy_association.target = proxy_association.owner.labelings.all
      end
      proxy_association.target.select{|assoc| assoc.is_a? labeling_class}
    end

    def available_names
      ['skos_pref_label'] + Iqvoc::Concept.labeling_class_names.map{|name, rest| name.constantize.relation_name}
    end

    protected

    base_labelings = {'skos_pref_label' => Iqvoc::Concept.pref_labeling_class_name.constantize}
    labelings = Iqvoc::Concept.further_labeling_class_names.inject(base_labelings) do |hash, name|
      klass = name.first.constantize
      hash[klass.relation_name] = klass
      hash
    end

    labelings.each do |relation_name, labeling_class|
      define_method relation_name do
        for_class labeling_class
      end

      define_method "#{relation_name}=" do |labelings|
#         assign_for_class labeling_class, labelings
        raise "don't do this!"
      end
    end

  end
end
