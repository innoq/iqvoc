require 'test_helper'
require 'iqvoc/skos_importer'

class SkosImportTest < ActiveSupport::TestCase

  TEST_DATA = (<<-DATA
<http://www.example.com/_animal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/_animal> <http://www.w3.org/2008/05/skos#prefLabel> "Tier"@de .
<http://www.example.com/_animal> <http://www.w3.org/2008/05/skos#prefLabel> "Animal"@en .
<http://www.example.com/_animal> <http://www.w3.org/2008/05/skos#altLabel> "Viehzeug"@de .
<http://www.example.com/_animal> <http://www.w3.org/2008/05/skos#definition> "Ein Tier ist kein Mensch."@de .
<http://www.example.com/_animal> <http://www.w3.org/2008/05/skos#narrower> <http://www.example.com/_cow> .
<http://www.example.com/_animal> <http://www.w3.org/2008/05/skos#narrower> <http://www.example.com/_donkey> .
<http://www.example.com/_animal> <http://www.w3.org/2008/05/skos#narrower> <http://www.example.com/_monkey> .
<http://www.example.com/_cow> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/_cow> <http://www.w3.org/2008/05/skos#prefLabel> "Kuh"@de .
<http://www.example.com/_cow> <http://www.w3.org/2008/05/skos#prefLabel> "Cow"@en .
<http://www.example.com/_cow> <http://www.w3.org/2008/05/skos#altLabel> "Rind"@de .
<http://www.example.com/_cow> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/_animal> .
<http://www.example.com/_donkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/_donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Esel"@de .
<http://www.example.com/_donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Donkey"@en .
<http://www.example.com/_donkey> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/_animal> .
<http://www.example.com/_monkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/_monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Affe"@de .
<http://www.example.com/_monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Monkey"@en .
<http://www.example.com/_monkey> <http://www.w3.org/2008/05/skos#altLabel> "\u00C4ffle"@de .
<http://www.example.com/_monkey> <http://www.w3.org/2008/05/skos#altLabel> "Ape"@en .
<http://www.example.com/_monkey> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/_animal> .
<http://www.example.com/_monkey> <http://www.w3.org/2008/05/skos#exactMatch> <http://dbpedia.org/page/Monkey> .
    DATA
  ).split("\n")

  test "basic_importer_functionality" do
    Iqvoc::SkosImporter.new(TEST_DATA, "http://www.example.com/")

    concepts = {}
    ["_animal", "_cow", "_donkey", "_monkey"].each do |origin|
      concepts[origin] = Iqvoc::Concept.base_class.by_origin(origin).last
      assert_not_nil(concepts[origin], "Couldn't find concept '#{origin}'.")
    end

    assert_equal "Tier", concepts["_animal"].pref_label('de').to_s

    broader_relation = concepts["_cow"].broader_relations.first
    assert_not_nil broader_relation
    assert_equal concepts["_animal"].origin, broader_relation.target.origin

    note = concepts["_animal"].note_skos_definitions.first
    assert_not_nil note
    assert_equal "Ein Tier ist kein Mensch.", note.value

    match = concepts["_monkey"].match_skos_exact_matches.first
    assert_not_nil match
    assert_equal "http://dbpedia.org/page/Monkey", match.value
  end

end
