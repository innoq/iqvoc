module Concept
  module RelationSubtypeExtensions
    extend Concept::Relation::ReverseRelationExtension

    def for_class(relation_class)
      if proxy_association.target.empty?
        proxy_association.target = proxy_association.owner.relations.all
      end
      proxy_association.target.select{|assoc| assoc.is_a? relation_class}
    end

    def available_names
      Iqvoc::Concept.further_relation_classes.map(&:relation_name) + %w(skos_broader skos_narrower)
    end

    def find_by_target_and_class(target_obj, target_class)
      self.for_class(target_class).find{|rel| rel.target == target_obj || rel.target_id == target_obj.id }
    end

    def by_id_and_rank(class_name)
      self.for_class(class_name).each_with_object({}) { |rel, hsh| hsh[rel.target] = rel.rank }
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
        raise "don't do this!"
      end
    end

  end
end
