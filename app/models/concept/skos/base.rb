# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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
  self.rdf_namespace = 'skos'
  self.rdf_class = 'Concept'

  def build_rdf_subject(&block)
    ns = IqRdf::Namespace.find_namespace_class(self.rdf_namespace)
    raise "Namespace '#{self.rdf_namespace}' is not defined in IqRdf document." unless ns
    subject = IqRdf.build_uri(self.origin, ns.build_uri(self.rdf_class), &block)

    # ensure skos:Concept type is present
    unless self.rdf_namespace == 'skos' && self.rdf_class == 'Concept'
      subject.Rdf.build_predicate('type', IqRdf::Skos.build_uri('Concept'))
    end

    return subject
  end

  # ********** Scopes
  def self.expired(time = Time.now)
    where(arel_table[:expired_at].lt(time))
  end

  def self.not_expired(time = Time.now)
    col = arel_table[:expired_at]
    where((col.eq(nil)).or(col.gteq(time)))
  end
end
