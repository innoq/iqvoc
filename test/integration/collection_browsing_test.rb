# encoding: UTF-8

# Copyright 2011-2022 innoQ Deutschland GmbH
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

class CollectionBrowsingTest < ActionDispatch::IntegrationTest
  setup do
    login('administrator')

    @indoor = Iqvoc::Collection.base_class.new.publish.tap do |c|
      RdfApi.devour c, 'skos:prefLabel', '"Indoors"@en'
      c.save
    end

    @outdoor = Iqvoc::Collection.base_class.new.publish.tap do |c|
      RdfApi.devour c, 'skos:prefLabel', '"Outdoors"@en'
      c.save
    end
  end

  test 'collection listing' do
    visit collections_path(lang: 'en')
    assert page.has_content?("#{@indoor.pref_label}")
    assert page.has_content?("#{@outdoor.pref_label}")
  end

  test 'showing published collection' do
    visit collection_path(@indoor, lang: 'en')
    assert page.has_content?('Collections')
    assert page.has_content?("#{@indoor.pref_label}")
  end
end
