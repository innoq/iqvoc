# # encoding: UTF-8
#
# # Copyright 2011-2014 innoQ Deutschland GmbH
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.
#
# require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
#
# class ConceptsControllerTest < ActionController::TestCase
#   setup do
#     @air_sports = Concept::SKOS::Base.new.tap do |c|
#       Iqvoc::RDFAPI.devour c, 'skos:prefLabel', '"Air sports"@en'
#       c.publish
#       c.save
#     end
#
#     @achievement_hobbies = Concept::SKOS::Base.new(top_term: true).tap do |c|
#       Iqvoc::RDFAPI.devour c, 'skos:prefLabel', '"Achievement hobbies"@en'
#       Iqvoc::RDFAPI.devour c, 'skos:narrower', @air_sports
#       c.publish
#       c.save
#     end
#
#     @sports = Concept::SKOS::Base.new(top_term: true).tap do |c|
#       Iqvoc::RDFAPI.devour c, 'skos:prefLabel', '"Sports"@en'
#       c.publish
#       c.save
#     end
#   end
#
#   test 'concept movement' do
#     # login('administrator')
#
#     assert_equal 1, @achievement_hobbies.narrower_relations.size
#     assert_equal @air_sports.id, @achievement_hobbies.narrower_relations.first.target.id
#     assert_equal 1, @air_sports.broader_relations.size
#     assert_equal 0, @sports.narrower_relations.size
#
#     # move air_sports from achievement hobbies => sports
#     patch :move, concept: {
#       tree_action: 'move',
#       moved_node_id: @air_sports.id,
#       old_parent_node_id: @achievement_hobbies.id,
#       new_parent_node_id: @sports.id
#     }
#
#     assert_equal 0, @achievement_hobbies.narrower_relations.size
#     assert_equal 1, @air_sports.broader_relations.size
#     assert_equal 1, @sports.narrower_relations.size
#
#     put
#   end
# end
