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

class Collection::Member::SKOS::Base < Collection::Member::Base

  acts_as_rdf_predicate 'skos:member'

  def self.build_from_parsed_tokens(tokens, options = {}) # <<collection>>, <<member>>, <<concept|collection>>
    rdf_subject     = options[:subject_instance] || Iqvoc::RDFAPI.cached(tokens[:SubjectOrigin])
    rdf_object      = options[:object_instance]  || Iqvoc::RDFAPI.cached(tokens[:ObjectOrigin])

    # FIXME: something fishy is going on here. probably first have to refactor member association
    member_instance = rdf_subject.members.to_a.find {|rel| rel.target == rdf_object || rel.target_id == rdf_object.id }

    if member_instance.nil?
      predicate_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[tokens[:Predicate]] || self
      member_instance = predicate_class.new(:collection => rdf_subject, :target => rdf_object)
      rdf_subject.members << member_instance

      if rdf_object.is_a?(Collection::Base)
#         raise "should not happen"
        rdf_subject.subcollections << rdf_object
      end
    end

    if rdf_object.collections.select{|coll| coll.id == rdf_subject.id || coll == rdf_subject}.empty?
      rdf_object.collections << rdf_subject
    end
    member_instance
  end
end
