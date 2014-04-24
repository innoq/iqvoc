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

    Iqvoc.config['languages.pref_labeling'] = ['de', 'en']
    Iqvoc.config['languages.further_labelings.Labeling::SKOS::AltLabel'] = ['de', 'en']

    @testdata = File.read(Rails.root.join('test','unit', 'testdata.nt')).split("\n")

    Iqvoc::SkosImporter.new(@testdata, 'http://www.example.com/').run
  end

  teardown do
    Iqvoc.config["languages.pref_labeling"] = ["en", "de"]
    Iqvoc.config["languages.further_labelings.Labeling::SKOS::AltLabel"] = ["en", "de"]
  end

  test "basic_exporter_functionality" do
    testfile = Rails.root.join('public/export/skos_export_test.ttl').to_s

    Iqvoc::SkosExporter.new(testfile, 'nt', 'http://www.example.com/').run

    generated_export = File.read(testfile)

    @testdata.each do |ntriple|
      assert generated_export.include?(ntriple), "could'n find ntriple '#{ntriple}' in #{generated_export}"
    end

    # delete export
    File.delete(testfile)
  end

end
