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

require 'iqvoc'
require 'iqvoc/data_helper'
require 'iqvoc/version'
require 'iqvoc/versioning'
require 'iqvoc/deep_cloning'
require 'iqvoc/rdf_helper'
require 'iqvoc/ability'

ActiveRecord::Base.send :include, Iqvoc::DeepCloning


##### INSTANCE SETTINGS #####

# uncomment the settings below and adjust as desired
# see lib/iqvoc.rb for the full list of available setting

if Rails.env != "test"

  # Iqvoc.title = "My Thesaurus"

  # interface languages (cf. config/locales)
  # available_languages = [ :en, :de ]

  # label languages (and classes)
  # Iqvoc::Concept.pref_labeling_languages      = [ :de, :en ]
  # Iqvoc::Concept.further_labeling_class_names = {
  #  "Labeling::SKOS::AltLabel" => [ :de, :en ]
  # }

end
