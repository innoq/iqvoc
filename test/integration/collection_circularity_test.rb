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

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

API = Iqvoc::RDFAPI

class CollectionCircularityTest < ActionDispatch::IntegrationTest
  setup do
    API.parse_triples <<-EOT
      :coll1 rdf:type skos:Collection
      :coll1 skos:prefLabel "Collection 1"@en
      :coll2 rdf:type skos:Collection
      :coll2 skos:prefLabel "Collection 2"@en
      :coll3 rdf:type skos:Collection
      :coll3 skos:prefLabel "Collection 3"@en

      :concept1 rdf:type skos:Concept
      :concept1 skos:prefLabel "Concept 1"@en
      :concept2 rdf:type skos:Concept
      :concept2 skos:prefLabel "Concept 3"@en
      :concept3 rdf:type skos:Concept
      :concept3 skos:prefLabel "Concept 3"@en
    EOT
  end

  test 'inline assignments are persisted' do
    login('administrator')

    visit edit_collection_path(API.cached('coll1'), :lang => 'en', :format => 'html')
    fill_in 'concept_inline_member_collection_origins',
        :with => 'coll2,coll3' # without space
    fill_in 'concept_inline_member_concept_origins',
        :with => 'concept1,concept2,concept3' # without space
    click_button 'Save'

    assert page.has_no_css?('.flash_error')
    assert page.has_content?(I18n.t('txt.controllers.collections.save.success'))
    assert page.has_link?(API.cached('coll2').pref_label.to_s)
    assert page.has_link?(API.cached('coll3').pref_label.to_s)
    assert page.has_link?(API.cached('concept1').pref_label.to_s)
    assert page.has_link?(API.cached('concept2').pref_label.to_s)
    assert page.has_link?(API.cached('concept3').pref_label.to_s)

    click_link_or_button 'Edit'
    fill_in 'concept_inline_member_collection_origins', :with => ''
    fill_in 'concept_inline_member_concept_origins', :with => ''
    click_button 'Save'

    assert page.has_no_css?('.flash_error')
    assert page.has_content?(I18n.t('txt.controllers.collections.save.success'))
    assert page.has_no_link?(API.cached('coll2').pref_label.to_s)
    assert page.has_no_link?(API.cached('coll3').pref_label.to_s)
    assert page.has_no_link?(API.cached('concept1').pref_label.to_s)
    assert page.has_no_link?(API.cached('concept2').pref_label.to_s)
    assert page.has_no_link?(API.cached('concept3').pref_label.to_s)

    click_link_or_button 'Edit'
    fill_in 'concept_inline_member_collection_origins',
        :with => 'coll2, coll3' # with space
    fill_in 'concept_inline_member_concept_origins',
        :with => 'concept1, concept2, concept3' # with space
    click_button 'Save'

    assert page.has_no_css?('.flash_error')
    assert page.has_content?(I18n.t('txt.controllers.collections.save.success'))
    assert page.has_link?(API.cached('coll2').pref_label.to_s)
    assert page.has_link?(API.cached('coll3').pref_label.to_s)
    assert page.has_link?(API.cached('concept1').pref_label.to_s)
    assert page.has_link?(API.cached('concept2').pref_label.to_s)
    assert page.has_link?(API.cached('concept3').pref_label.to_s)
  end

  test 'circular sub-collection references are rejected during update' do
    login('administrator')

    # add coll2 as subcollection of coll1
    visit edit_collection_path(API.cached('coll1'), :lang => 'en', :format => 'html')
    fill_in 'concept_inline_member_collection_origins',
        :with => 'coll2,'
    click_button 'Save'

    assert page.has_no_css?('.flash_error')
    assert page.has_content?(I18n.t('txt.controllers.collections.save.success'))
    assert page.has_link?(API.cached('coll2').pref_label.to_s,
        :href => collection_path(API.cached('coll2'), :lang => 'en', :format => 'html'))

    # add coll1 as subcollection of coll2
    visit edit_collection_path(API.cached('coll2'), :lang => 'en', :format => 'html')
    fill_in 'concept_inline_member_collection_origins',
        :with => 'coll1,'
    click_button 'Save'

    assert page.has_css?('.alert-error')
    assert page.has_css?('#edit_concept')
    assert page.has_content?( # XXX: page.has_content? didn't work
        I18n.t('txt.controllers.collections.circular_error', :label => API.cached('coll1').pref_label))

    # ensure coll1 is not a subcollection of coll2
    visit collection_path(API.cached('coll2'), :lang => 'en', :format => 'html')
    assert page.has_no_css?('.relation ul.treeview li') # XXX: too unspecific
  end
end
