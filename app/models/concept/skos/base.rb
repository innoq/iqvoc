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

class Concept::SKOS::Base < Concept::Base

  self.rdf_namespace = "skos"
  self.rdf_class = "Concept"

  def build_rdf_subject(document, controller, &block)
    base_namespace = :skos
    base_type = "Concept"

    ns = IqRdf::Namespace.find_namespace_class(base_namespace)
    raise "Namespace '#{base_namespace}' is not defined in IqRdf document." unless ns
    subject = IqRdf.build_uri(self.origin, ns.build_uri(base_type), &block)

    # additional RDF type
    unless self.rdf_namespace == "skos" && self.rdf_class == "Concept"
      subject.Rdf::type(IqRdf.const_get(self.rdf_namespace.capitalize).
          build_uri(self.rdf_class))
    end

    return subject
  end

end
