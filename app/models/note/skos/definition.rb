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

class Note::SKOS::Definition < Note::SKOS::Base

  self.rdf_predicate = 'definition'

  static_attr "view_section", "main"
  static_attr "view_section_sort_key", 500 # show near the end of the section
  static_attr "search_result_partial_name", "partials/note/skos/definition/search_result"

end
