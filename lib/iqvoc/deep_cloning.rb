# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Iqvoc
  module DeepCloning

    def self.included(base) #:nodoc:
      base.alias_method_chain :dup, :deep_cloning
    end

    # clones an ActiveRecord model.
    # if passed the :include option, it will deep clone the given associations
    # if passed the :except option, it won't clone the given attributes
    #
    # === Usage:
    #
    # ==== Cloning a model without an attribute
    # pirate.clone :except => :name
    #
    # ==== Cloning a model without multiple attributes
    # pirate.clone :except => [:name, :nick_name]
    # ==== Cloning one single association
    # pirate.clone :include => :mateys
    #
    # ==== Cloning multiple associations
    # pirate.clone :include => [:mateys, :treasures]
    #
    # ==== Cloning really deep
    # pirate.clone :include => {:treasures => :gold_pieces}
    #
    # ==== Cloning really deep with multiple associations
    # pirate.clone :include => [:mateys, {:treasures => :gold_pieces}]
    #
    # ==== Cloning multiple associations - but only the join table entries without cloning the associated objects themselves
    # pirate.clone :include_association => [:matey_ids, :treasure_ids]
    #
    def dup_with_deep_cloning(options = {})
      kopy = dup_without_deep_cloning

      if options[:except]
        Array(options[:except]).each do |attribute|
          kopy.write_attribute(attribute, attributes_from_column_definition[attribute.to_s])
        end
      end

      if options[:include_association]
        Array(options[:include_association]).each do |association_attribute|
          kopy.send("#{association_attribute}=", self.send("#{association_attribute}"))
        end
      end

      if options[:include]
        Array(options[:include]).each do |association, deep_associations|
          if (association.kind_of? Hash)
            deep_associations = association[association.keys.first]
            association = association.keys.first
          end
          opts = deep_associations.blank? ? {} : {:include => deep_associations}
          association_reflection = self.class.reflect_on_association(association)
          cloned_object = case association_reflection.macro
          when :belongs_to, :has_one
            self.send(association) && self.send(association).dup(opts)
          when :has_many, :has_and_belongs_to_many
            fk = association_reflection.options[:foreign_key]# || self.class.to_s.underscore
            self.send(association).collect do |obj|
              cloned_obj = obj.dup(opts)
              cloned_obj.send("#{fk}=", kopy) unless fk.blank?
              cloned_obj
            end
          end
          kopy.send("#{association}=", cloned_object)
        end
      end

      return kopy
    end

  end
end
