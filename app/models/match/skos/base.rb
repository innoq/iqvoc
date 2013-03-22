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

class Match::SKOS::Base < Match::Base

  def build_rdf(document, subject)
    raise "#{self.class}#build_rdf: Class #{self.name} needs to call acts_as_rdf_predicate 'ns:type'." unless self.implements_rdf?

    if (IqRdf::Namespace.find_namespace_class(self.rdf_namespace.camelcase))
      subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, URI.parse(value))
    else
      raise "#{self.class}#build_rdf: couldn't find Namespace '#{self.rdf_namespace.camelcase}'."
    end
  end

  def self.build_from_parsed_tokens(tokens)
    rdf_subject = Iqvoc::RDFAPI.cached(tokens[:SubjectOrigin])
    match_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[tokens[:Predicate]] || self
    match_class.new(:value => tokens[:ObjectUri], :concept => rdf_subject)
  end

end