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
require 'iqvoc/skos_importer'

class SkosImportTest < ActiveSupport::TestCase

  setup do
    Iqvoc::Concept.pref_labeling_class_name = 'Labeling::SKOS::PrefLabel'

    Iqvoc.config["languages.pref_labeling"] = ["de", "en"]
    Iqvoc.config["languages.further_labelings.Labeling::SKOS::AltLabel"] = ["de", "en"]
  end

  teardown do
    Iqvoc.config["languages.pref_labeling"] = ["en", "de"]
    Iqvoc.config["languages.further_labelings.Labeling::SKOS::AltLabel"] = ["en", "de"]
  end

  TEST_DATA = (<<-DATA
<http://www.example.com/animal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#prefLabel> "Tier"@de .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#prefLabel> "Animal"@en .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#altLabel> "Viehzeug"@de .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#definition> "Ein Tier ist kein Mensch."@de .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#narrower> <http://www.example.com/cow> .
<http://www.example.com/cow> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Kuh"@de .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Cow"@en .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#altLabel> "Rind"@de .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/animal> .
<http://www.example.com/donkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Esel"@de .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Donkey"@en .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/animal> .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Affe"@de .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Monkey"@en .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#altLabel> "\u00C4ffle"@de .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#altLabel> "Ape"@en .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/animal> .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#exactMatch> <http://dbpedia.org/page/Monkey> .
<http://www.example.com/monkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://not-my-problem.com/me> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept>.
    DATA
  ).split("\n")

  test "unicode json decoding trick" do
    encoded_val = "\\u00C4ffle"
    decoded_val = JSON.parse(%Q{["#{encoded_val}"]})[0].gsub("\\n", "\n")
    assert_equal decoded_val, "Äffle"
  end

  test "basic_importer_functionality" do
    assert_difference('Concept::SKOS::Base.count', 4) do
      Iqvoc::SkosImporter.new(TEST_DATA, "http://www.example.com/").run
    end

    concepts = {}
    ["animal", "cow", "donkey", "monkey"].each do |origin|
      concepts[origin] = Iqvoc::Concept.base_class.by_origin(origin).last
      assert_not_nil(concepts[origin], "Couldn't find concept '#{origin}'.")
      assert concepts[origin].published?, "Concept '#{origin}' wasn't published."
    end

    assert_equal "Animal", concepts["animal"].pref_label.to_s

    broader_relation = concepts["cow"].broader_relations.first
    assert_not_nil broader_relation
    assert_not_nil broader_relation.target
    assert_equal concepts["animal"].origin, broader_relation.target.origin

    narrower_relations = concepts["animal"].narrower_relations
    assert_equal 3, narrower_relations.count

    note = concepts["animal"].note_skos_definitions.first
    assert_not_nil note
    assert_equal "Ein Tier ist kein Mensch.", note.value

    match = concepts["monkey"].match_skos_exact_matches.first
    assert_not_nil match
    assert_equal "http://dbpedia.org/page/Monkey", match.value
  end

  test "incorrect origin" do
    assert_difference('Concept::SKOS::Base.count', 1) do
      Iqvoc::SkosImporter.new(["<http://www.example.com/1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept>."], "http://www.example.com/").run
    end
    assert_nil Iqvoc::Concept.base_class.by_origin("1").last
    assert_not_nil Iqvoc::Concept.base_class.by_origin("_1").last
  end

  test "blank nodes" do
    test_data = (<<-DATA
      <http://www.example.com/car> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
      <http://www.example.com/car> <http://www.w3.org/2008/05/skos#prefLabel> "Car"@en .
      <http://www.example.com/car> <http://www.w3.org/2004/02/skos/core#changeNote> _:A01 .
      _:A01 <http://purl.org/dc/terms/modified> "2012-02-13T08:56:13+01:00" .
      _:A01 <http://purl.org/dc/terms/creator> "Arnulf Beckenbauer" .
      DATA
    ).split("\n")

    assert_difference('Note::SKOS::ChangeNote.count', 1) do
      Iqvoc::SkosImporter.new(test_data, "http://www.example.com/").run
    end

    assert_difference('Note::Annotated::Base.count', 2) do
      Iqvoc::SkosImporter.new(test_data, "http://www.example.com/").run
    end
  end

  test "notations" do
    test_data = (<<-DATA
      <http://www.example.com/car> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
      <http://www.example.com/car> <http://www.w3.org/2008/05/skos#notation> "ME-IQ 1234"^^<http://www.example.com/licensePlate> .
      <http://www.example.com/car> <http://www.w3.org/2008/05/skos#notation> "12345"^^<http://notations.example.com/exampleNotation> .
      DATA
    ).split("\n")

    assert_difference('Notation::Base.count', 2) do
      Iqvoc::SkosImporter.new(test_data, "http://www.example.com/").run
    end
  end

  test "top concepts for concept scheme" do
    test_data = (<<-DATA
      <http://www.example.com/car> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
      <http://www.example.com/car> <http://www.w3.org/2008/05/skos#topConceptOf> <http://www.example.com/scheme> .
      <http://www.example.com/pedal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
      <http://www.example.com/steering_wheel> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
      DATA
    ).split("\n")

    assert_difference('Concept::SKOS::Base.tops.count', 1) do
      Iqvoc::SkosImporter.new(test_data, "http://www.example.com/").run
    end
  end
end

class SkosCollectionImportTest < ActiveSupport::TestCase
  setup do
    Iqvoc::Concept.pref_labeling_class_name = 'Labeling::SKOS::PrefLabel'

    Iqvoc.config.register_setting("languages.pref_labeling", ["de", "en"])
    Iqvoc.config.register_setting("languages.further_labelings.Labeling::SKOS::AltLabel", ["de", "en"])
  end

  TEST_DATA = (<<-DATA
<http://www.example.com/land-animal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Collection> .
<http://www.example.com/land-animal> <http://www.w3.org/2008/05/skos#prefLabel> "Landtier"@de .
<http://www.example.com/land-animal> <http://www.w3.org/2008/05/skos#prefLabel> "Land animal"@en .
<http://www.example.com/legged-animal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Collection> .
<http://www.example.com/legged-animal> <http://www.w3.org/2008/05/skos#prefLabel> "Vierbeinige Tier"@de .
<http://www.example.com/legged-animal> <http://www.w3.org/2008/05/skos#prefLabel> "Four legged animal"@en .
<http://www.example.com/cow> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Kuh"@de .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Cow"@en .
<http://www.example.com/snake> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/snake> <http://www.w3.org/2008/05/skos#prefLabel> "Schlange"@de .
<http://www.example.com/snake> <http://www.w3.org/2008/05/skos#prefLabel> "Snake"@en .
<http://www.example.com/donkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Esel"@de .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Donkey"@en .
<http://www.example.com/legged-animal> <http://www.w3.org/2004/02/skos/core#member> <http://www.example.com/cow> .
<http://www.example.com/legged-animal> <http://www.w3.org/2004/02/skos/core#member> <http://www.example.com/donkey> .
<http://www.example.com/land-animal> <http://www.w3.org/2004/02/skos/core#member> <http://www.example.com/legged-animal> .
<http://www.example.com/land-animal> <http://www.w3.org/2004/02/skos/core#member> <http://www.example.com/snake> .
     DATA
    ).split("\n")

  test "basic importer functionality" do
    assert_difference('Collection::Base.count', 2) do
      Iqvoc::SkosImporter.new(TEST_DATA, "http://www.example.com/").run
    end
    concepts = {}
    ["cow", "donkey", "snake"].each do |origin|
      concepts[origin] = Iqvoc::Concept.base_class.by_origin(origin).last
      assert_not_nil(concepts[origin], "Couldn't find concept '#{origin}'.")
      assert concepts[origin].published?, "Concept '#{origin}' wasn't published."
    end

    collections = {}
    ["land-animal", "legged-animal"].each do |origin|
      collections[origin] = Iqvoc::Collection.base_class.by_origin(origin).last
      assert_not_nil(collections[origin], "Couldn't find collections '#{origin}'.")
      assert collections[origin].published?, "collections '#{origin}' wasn't published."
    end

    collection_with_member = concepts["cow"].collections.first
    assert_not_nil collection_with_member

    concept_member = collections["land-animal"].members.first
    assert_not_nil concept_member
  end

  test "subcollections importer functionality" do
    assert_difference('Collection::Base.count', 2) do
      Iqvoc::SkosImporter.new(TEST_DATA, "http://www.example.com/").run
    end

    collection_with_subcollections = Iqvoc::Collection.base_class.by_origin("land-animal").last
    assert_not_nil collection_with_subcollections
    assert_not_nil collection_with_subcollections.subcollections.first
  end

  test "empty string import"  do
    test_data = (<<-DATA
      <http://www.example.com/water-animal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Collection> .
      <http://www.example.com/water-animal> <http://www.w3.org/2008/05/skos#prefLabel> ""@de .
    DATA
    ).split("\n")

    assert_nothing_raised do
    assert_difference('Collection::Base.count', 1) do
      Iqvoc::SkosImporter.new(test_data, "http://www.example.com/").run
      end
    end
  end
end
