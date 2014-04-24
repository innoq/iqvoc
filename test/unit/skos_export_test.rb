# encoding: UTF-8

# Copyright 2011-2014 innoQ Deutschland GmbH
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
require 'iqvoc/skos_exporter'
require 'iqvoc/skos_importer'

class SkosExportTest < ActiveSupport::TestCase

  setup do
    Iqvoc::Concept.pref_labeling_class_name = 'Labeling::SKOS::PrefLabel'

    Iqvoc.config["languages.pref_labeling"] = ["de", "en"]
    Iqvoc.config["languages.further_labelings.Labeling::SKOS::AltLabel"] = ["de", "en"]

    TEST_DATA = (<<-DATA
<http://0.0.0.0:3000/animal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://0.0.0.0:3000/animal> <http://www.w3.org/2008/05/skos#prefLabel> "Tier"@de .
<http://0.0.0.0:3000/animal> <http://www.w3.org/2008/05/skos#prefLabel> "Animal"@en .
<http://0.0.0.0:3000/animal> <http://www.w3.org/2008/05/skos#altLabel> "Viehzeug"@de .
<http://0.0.0.0:3000/animal> <http://www.w3.org/2008/05/skos#definition> "Ein Tier ist kein Mensch."@de .
<http://0.0.0.0:3000/animal> <http://www.w3.org/2008/05/skos#narrower> <http://0.0.0.0:3000/cow> .
<http://0.0.0.0:3000/cow> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://0.0.0.0:3000/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Kuh"@de .
<http://0.0.0.0:3000/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Cow"@en .
<http://0.0.0.0:3000/cow> <http://www.w3.org/2008/05/skos#altLabel> "Rind"@de .
<http://0.0.0.0:3000/cow> <http://www.w3.org/2008/05/skos#broader> <http://0.0.0.0:3000/animal> .
<http://0.0.0.0:3000/donkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://0.0.0.0:3000/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Esel"@de .
<http://0.0.0.0:3000/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Donkey"@en .
<http://0.0.0.0:3000/donkey> <http://www.w3.org/2008/05/skos#broader> <http://0.0.0.0:3000/animal> .
<http://0.0.0.0:3000/monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Affe"@de .
<http://0.0.0.0:3000/monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Monkey"@en .
<http://0.0.0.0:3000/monkey> <http://www.w3.org/2008/05/skos#altLabel> "\u00C4ffle"@de .
<http://0.0.0.0:3000/monkey> <http://www.w3.org/2008/05/skos#altLabel> "Ape"@en .
<http://0.0.0.0:3000/monkey> <http://www.w3.org/2008/05/skos#broader> <http://0.0.0.0:3000/animal> .
<http://0.0.0.0:3000/monkey> <http://www.w3.org/2008/05/skos#exactMatch> <http://dbpedia.org/page/Monkey> .
<http://0.0.0.0:3000/monkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
    DATA
    ).split("\n")

    Iqvoc::SkosImporter.new(TEST_DATA, "http://0.0.0.0:3000/").run
  end

  teardown do
    Iqvoc.config["languages.pref_labeling"] = ["en", "de"]
    Iqvoc.config["languages.further_labelings.Labeling::SKOS::AltLabel"] = ["en", "de"]
  end


  test "basic_exporter_functionality" do
    testfile = Rails.root.join('public/export/skos_export_test.ttl').to_s

    Iqvoc::SkosExporter.new(testfile, 'ttl').run

    generated_export = File.read(testfile)

    TEST_DATA.each do |ntriple|
      assert generated_export.include?(ntriple), "could'n find ntriple '#{ntriple}'"
    end

    # delete export
    File.delete(testfile)
  end

end
