module Iqvoc
  module Configuration
    # Engines register further associations on concepts and labels. A
    # registration names the foreign key, and may wrap it in a hash to say
    # which belongs_to on the other side it inverts:
    #
    #   'Inflectional::Base' => 'label_id'
    #   'Inflectional::Base' => { foreign_key: 'label_id', inverse_of: :label }
    #
    # The inverse matters for more than tidiness. The generated has_many passes
    # foreign_key, which switches off Rails' automatic inverse detection, so
    # without it every rendered child reloads the record it belongs to - one
    # query per child.
    module AdditionalAssociations
      module_function

      # Registrations as class => { foreign_key:, inverse_of: }.
      def normalize(class_names)
        class_names.each_with_object({}) do |(class_name, registration), result|
          options = registration.is_a?(Hash) ? registration.symbolize_keys : { foreign_key: registration }
          association_class = class_name.constantize

          unless options.key?(:inverse_of)
            options[:inverse_of] = derive_inverse_of(association_class, options[:foreign_key])
          end

          result[association_class] = options
        end
      end

      # Preloader specification for the registered associations. A registration
      # may name what to preload underneath itself, for associations whose
      # rendering reaches further than the record itself:
      #
      #   'CompoundForm::Base' => { foreign_key: 'domain_id',
      #                             preload: { compound_form_contents: :label } }
      def preload_spec(class_names)
        normalize(class_names).map do |association_class, options|
          name = association_class.name.to_relation_name
          options[:preload] ? { name => options[:preload] } : name
        end
      end

      # A registration that names no inverse is assumed to follow its foreign
      # key. The guess is dropped when no such association exists, so that a
      # registration naming it differently keeps working - slowly, but
      # correctly. Name the inverse explicitly to turn that into an error.
      def derive_inverse_of(association_class, foreign_key)
        name = foreign_key.to_s.delete_suffix('_id').to_sym
        name if association_class.reflect_on_association(name)
      end
    end
  end
end
