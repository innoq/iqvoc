require 'iqvoc'

require 'iqvoc_global/versioning'
require 'iqvoc_global/deep_cloning'
require 'iqvoc_global/rdf_helper'

ActiveRecord::Base.send :include, IqvocGlobal::DeepCloning

Iqvoc::Concept.pref_labeling_class_name     = 'Labeling::SKOS::PrefLabel'
Iqvoc::Concept.note_class_names             = [ 'Note::SKOS::Base', 'Note::SKOS::Definition' ]

Iqvoc::Concept.pref_labeling_languages      = [ :de, :en ]
Iqvoc::Concept.further_labeling_class_names = { 'Labeling::SKOS::AltLabel' => [ :de, :en ] }

