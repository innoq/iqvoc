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

class Note::SKOS::Base < Note::Base

  def build_rdf(document, subject)
    ns, id = '', ''
    if self.implements_rdf?
      ns, id = self.rdf_namespace, self.rdf_predicate
    elsif self.class == Note::SKOS::Base # This could be done by setting self.rdf_predicate to 'note'. But all subclasses would inherit this value.
      ns, id = 'Skos', 'note'
    else
      raise "#{self.class.name}#build_rdf: Class #{self.class.name} needs to acts_as_rdf_predicate."
    end

    if (IqRdf::Namespace.find_namespace_class(ns))
      subject.send(ns).send(id, value, :lang => language)
    else
      raise "#{self.class.name}#build_rdf: couldn't find Namespace '#{ns}'."
    end
  end

end
