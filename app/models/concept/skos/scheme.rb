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

require 'singleton'

# virtual root node
# NB:
# * does not inherit from Concept::Base to avoid being included in all
#   queries based on that class, including indirect ones (e.g. relations)
# * persistence (i.e. a database record) is not required since this is a
#   singleton and merely a static, virtual node
class Concept::SKOS::Scheme
  include Singleton
  include ActsAsRdfClass

  acts_as_rdf_class 'skos:ConceptScheme'

  def origin
    :scheme
  end

  def build_rdf_subject(&block)
    ns = IqRdf::Namespace.find_namespace_class(self.class.rdf_namespace.to_sym)
    raise "Namespace '#{rdf_namespace}' is not defined in IqRdf document." unless ns
    IqRdf.build_uri(origin, ns.build_uri(self.class.rdf_class), &block)
  end

end
