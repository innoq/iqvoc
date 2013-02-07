module Concept
  module RelationSubtypeExtensions
    extend Concept::Relation::ReverseRelationExtension

    def for_class(relation_class)
      if proxy_association.target.empty?
        proxy_association.owner.relations.to_a
      end
      proxy_association.target.select{|assoc| assoc.is_a? relation_class}
    end

    def assign_for_class(relation_class, relations)
      for_class(relation_class).each &:destroy
      relations.each do |relation|
        proxy_association.target << relation
      end
    end

    def available_names
      Iqvoc::Concept.further_relation_classes.map(&:relation_name) + %w(skos_broader skos_narrower)
    end

    protected

    base_assocs = {
      'skos_broader'  => Iqvoc::Concept.broader_relation_class,
      'skos_narrower' => Iqvoc::Concept.broader_relation_class.narrower_class
    }
    assocs = Iqvoc::Concept.further_relation_class_names.inject(base_assocs) {|hash, name| hash[name.constantize.relation_name] = name.constantize; hash}

    assocs.each do |relation_name, relation_class|
      define_method relation_name do
        for_class relation_class
      end

      define_method "#{relation_name}=" do |relations|
        assign_for_class relation_class, relations
      end
    end
  end
end
