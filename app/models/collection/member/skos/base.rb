# encoding: UTF-8

# Copyright 2012 Hola, S.L.
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

  self.rdf_namespace = "skos"
  self.rdf_predicate = "member"

  def self.build_from_rdf(subject, predicate, object)
    raise "Labeling::SKOS::Base#build_from_rdf: Subject (#{subject}) must be a Collection." unless subject.is_a?(Collection::Base)
    raise "Labeling::SKOS::Base#build_from_rdf: Object (#{object}) must be a Collection or Concept." unless object.is_a?(Collection::Base) or object.is_a?(Concept::Base)

    if subject.send(:members).select{|rel| rel.collection_id == subject.id || rel.target == object}.empty?
      subject.send(:members) << self.new(:target => object)
      if object.is_a?(Collection::Base)
        subject.send(:subcollections) << object
      end
    end

    if object.send(:collections).select{|coll| coll.id == subject.id}.empty?
      object.send(:collections) << subject
    end
  end
end
