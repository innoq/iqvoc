module Concept
  module LabelingSubtypeExtensions
    def for_class(labeling_class)
      load_association_if_empty
      proxy_association.target.select{|assoc| assoc.type.to_s == labeling_class.to_s}
    end

    def for_rdf_class(rdf_class)
      load_association_if_empty
      proxy_association.target.select{|assoc| assoc.implements_rdf? rdf_class}
    end

    def available_names
      ['skos_pref_label'] + Iqvoc::Concept.labeling_class_names.map{|name, rest| name.constantize.relation_name}
    end

    protected

    def load_association_if_empty
      if proxy_association.target.empty?
        proxy_association.target = proxy_association.owner.labelings.includes(:target).all
      end
    end

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
        raise "don't do this!"
      end
    end

  end
end
