require 'iqvoc'

require 'iqvoc_global/versioning'
require 'iqvoc_global/deep_cloning'
require 'iqvoc_global/rdf_helper'

ActiveRecord::Base.send :include, IqvocGlobal::DeepCloning

Iqvoc::Concept.note_class_names += [
  'Note::UMT::ChangeNote',
  'Note::UMT::ExportNote',
  'Note::UMT::SourceNote',
  'Note::UMT::UsageNote'
]

Iqvoc::XLLabel.base_class_name = 'Label::UMT::Base'

Iqvoc::XLLabel.relation_class_names += [
  'Label::Relation::UMT::Translation',
  'Label::Relation::UMT::Homograph',
  'Label::Relation::UMT::Qualifier',
  'Label::Relation::UMT::LexicalExtension'
]

Iqvoc::XLLabel.note_class_names = Iqvoc::Concept.note_class_names

Iqvoc::XLLabel.additional_association_classes.merge(
  "Inflectional::Base" => "label_id",
  "CompoundForm::Base" => "domain_id",
  "CompoundForm::Content::Base" => "label_id" # This is used for the reverse direction ('compound_in')
)

Iqvoc::XLLabel.view_sections << "compound_forms"

Iqvoc::XLLabel.has_additional_base_data = true