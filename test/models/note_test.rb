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

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class NoteTest < ActiveSupport::TestCase
  test 'should parse turtle note annotations' do
    str = '[umt:source <aDisBMS>; umt:thsisn "00000001"; dct:date "2010-04-29"]'
    concept = Concept::Skos::Base.create(origin: '_00000001', published_at: Time.now)
    concept.note_skos_change_notes << ::Note::Skos::ChangeNote.new.from_annotation_list!(str)

    assert_equal 1, Note::Skos::ChangeNote.count, 1
    assert_equal 3, Note::Skos::ChangeNote.first.annotations.count, 3
    assert_equal 1, Note::Annotated::Base.where(namespace: 'umt',
        predicate: 'thsisn', value: '"00000001"').count
  end
end
