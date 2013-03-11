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

class Note::Annotated::Base < ActiveRecord::Base # FIXME: Why isn't this Note::Annotation::Base? This looks like an annotated note - but it is an annotation *for* a note!?

  self.table_name = 'note_annotations'

  belongs_to :note, :class_name => Note::Base.name

  def identifier
    (self.namespace && self.predicate) ?
        [self.namespace, self.predicate].join(':') :
        (self.namespace || self.predicate)
  end

end
