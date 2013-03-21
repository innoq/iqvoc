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

class Concept::Relation::SKOS::Base < Concept::Relation::Base

  after_save :save_reverse_instance

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    ActiveSupport::Deprecation.warn "build_from_rdf will be removed. Please use build_from_parsed_tokens in the future."

    rdf_subject    = Concept::Base.from_origin_or_instance(rdf_subject)
    rdf_object     = Concept::Base.from_origin_or_instance(rdf_object)
    relation_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self

    relation_instance = rdf_subject.relations.find_by_target_and_class(rdf_object, relation_class)
    unless relation_instance
      relation_instance = relation_class.new(:target => rdf_object, :owner => rdf_subject)
    end

    if relation_class.bidirectional?
      reverse_class       = relation_class.reverse_relation_class
      @reverse_instance   = rdf_object.relations.find_by_target_and_class(rdf_subject, reverse_class)
      @reverse_instance ||= reverse_class.new(:target => rdf_subject, :owner => rdf_object)
    end
    relation_instance
  end

  def self.build_from_parsed_tokens(tokens, options = {})
    rdf_subject    = options[:subject_instance] || Iqvoc::RDFAPI.cached(tokens[:SubjectOrigin])
    rdf_object     = options[:object_instance]  || Iqvoc::RDFAPI.cached(tokens[:ObjectOrigin])
    relation_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[tokens[:Predicate]] || self

    relation_instance = rdf_subject.relations.find_by_target_and_class(rdf_object, relation_class)
    unless relation_instance
      relation_instance = relation_class.new(:target => rdf_object, :owner => rdf_subject)
      relation_instance.rank = options[:object_rank] if options[:object_rank]
    end

    if relation_class.bidirectional?
      reverse_class       = relation_class.reverse_relation_class
      @reverse_instance   = rdf_object.relations.find_by_target_and_class(rdf_subject, reverse_class)
      @reverse_instance ||= reverse_class.new(:target => rdf_subject, :owner => rdf_object)
    end

    # NOTE: this is not really clean: We create two object instances for a single
    # RDF 'statement', which does not go nicely with the idea that we can just call
    # 'save' on the return value of this method to persist a statement (e.g. in RDFAPI.eat)
    # We should seriously consider building and persisting the reverse association in a
    # before_save callback instead.
    relation_instance
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, IqRdf.build_uri(target.origin))
  end

  protected

  def save_reverse_instance
    if @reverse_instance and (@reverse_instance.new_record? or @reverse_instance.dirty?)
      @reverse_instance.save
    end
  end

end
