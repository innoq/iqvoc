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

class SkosExportTest < ActiveSupport::TestCase
  setup do
    @testdata = File.read(Rails.root.join('data', 'hobbies.nt')).split("\n")
    @export_file = Rails.root.join('tmp/export/skos_export_test.nt').to_s

    SkosImporter.new(@testdata, 'http://hobbies.com/').run
  end

  test 'basic_exporter_functionality' do
    SkosExporter.new(@export_file, 'nt', 'http://hobbies.com/').run

    generated_export = File.read(@export_file)

    @testdata.each do |ntriple|
      assert generated_export.include?(ntriple), "couldn't find ntriple '#{ntriple}' in generated_export"
    end

    # delete export
    File.delete(@export_file)
  end

  # SkosExporter#add_concepts preloaded nothing for two years, because
  # Model.preload builds a relation instead of loading the records handed to
  # it. Nothing about the export broke, it just issued queries per concept, so
  # guard the property rather than the call.
  test 'associations are loaded per batch instead of per concept' do
    concepts = Iqvoc::Concept.base_class.published.count
    assert_operator concepts, :>, 10, 'fixture too small to tell preloading apart'

    annotate_concepts

    loads = count_loads

    # the scheme is a singleton whose lookup used to run once per concept
    names = ['Labeling::Base Load', 'Note::Skos::Definition Load', 'Match::Base Load',
        'Note::Annotated::Base Load', "#{Iqvoc::Concept.root_class} Load"]

    names.each do |name|
      assert_operator loads[name], :<, concepts,
          "expected '#{name}' to be preloaded, got #{loads[name]} queries for #{concepts} concepts"
    end
  end

  test 'skos exporter with an unknown export type' do
    assert_raise RuntimeError do
      SkosExporter.new(@export_file, 'txt', 'http://hobbies.com/')
    end

  end

  # render_concept only renders notes when change notes are shown, so preloading
  # them regardless would fetch and instantiate them for nothing
  test 'notes are only preloaded when change notes are rendered' do
    annotate_concepts
    show_change_notes = Iqvoc.rdf_show_change_notes

    begin
      # the concept preload shows up as Note::Base, not as the concrete
      # subclass: Note::Skos::Definition comes from rendering collections
      Iqvoc.rdf_show_change_notes = true
      rendered = count_loads['Note::Base Load']

      Iqvoc.rdf_show_change_notes = false
      skipped = count_loads['Note::Base Load']
    ensure
      Iqvoc.rdf_show_change_notes = show_change_notes
    end

    assert_operator skipped, :<, rendered,
        'expected fewer note queries when change notes are not rendered'
  end

  private

  # the fixture carries no annotations, but rendering them used to sort with
  # order(), which discards the preloaded association again
  def annotate_concepts
    Iqvoc::Concept.base_class.published.each_with_index do |concept, i|
      note = Note::Skos::Definition.create!(owner: concept, value: "Definition #{i}", language: 'de')
      Note::Annotated::Base.create!(note: note, namespace: 'skos', predicate: 'zeta', value: 'z')
      Note::Annotated::Base.create!(note: note, namespace: 'skos', predicate: 'alpha', value: 'a')
    end
  end

  # runs an export and returns the number of queries per Active Record name
  def count_loads
    loads = Hash.new(0)
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      loads[payload[:name].to_s] += 1
    end
    begin
      SkosExporter.new(@export_file, 'nt', 'http://hobbies.com/', Logger.new(IO::NULL)).run
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
      File.delete(@export_file) if File.exist?(@export_file)
    end
    loads
  end
end
