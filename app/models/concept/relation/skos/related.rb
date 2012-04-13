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

class Concept::Relation::SKOS::Related < Concept::Relation::SKOS::Base
  self.rdf_predicate = 'related'

  def build_rdf(document, subject)
    super
    if self.class.rankable?
      predicate = "ranked#{rdf_predicate.titleize}"

      subject.Schema.build_predicate(predicate) do |blank_node|
        blank_node.Schema.relationWeight(rank)
        blank_node.Schema.relationTarget(IqRdf.build_uri(target.origin))
      end
    end
  end

end
