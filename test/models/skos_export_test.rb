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
    @testdata = File.read(Rails.root.join('data', 'hobbies.nt')).split("\n")
    @export_file = Rails.root.join('tmp/export/skos_export_test.nt').to_s

    Iqvoc::SkosImporter.new(@testdata, 'http://hobbies.com/').run
  end

  test 'basic_exporter_functionality' do
    Iqvoc::SkosExporter.new(@export_file, 'nt', 'http://hobbies.com/').run

    generated_export = File.read(@export_file)

    @testdata.each do |ntriple|
      assert generated_export.include?(ntriple), "could'n find ntriple '#{ntriple}' in generated_export"
    end

    # delete export
    File.delete(@export_file)
  end

  test 'skos exporter with an unknown export type' do
    assert_raise RuntimeError do
      Iqvoc::SkosExporter.new(@export_file, 'txt', 'http://hobbies.com/')
    end

  end

end
