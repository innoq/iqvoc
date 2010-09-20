#### Concept stuff
Factory.define :concept do |c|
  c.sequence(:origin) { |n| "_000000#{n}" }
  c.published_at 3.days.ago
end

Factory.define :concept_with_association, :parent => :concept do |c|
  c.classifications {|a| [a.association(:classification), a.association(:classification)]}
  c.matches {|a| [a.association(:narrower_match), a.association(:close_match), a.association(:exact_match), a.association(:broader_match), a.association(:related_match)]}
  c.notes {|a| [a.association(:history_note, :owner_type => "Concept"), a.association(:umt_source_note, :owner_type => "Concept")]}
end

Factory.define :published_concept, :parent => :concept do |c|
  c.published_at 3.days.ago
end


#### Label stuff
Factory.define :label, :class => Label do |l|
  l.origin 'Forest'
  l.language 'en'
  l.value 'Forest'
end

#specialized label factory
Factory.define :label_with_association, :parent => :label do |l|
  l.labelings {|a| [a.association(:pref_labeling), a.association(:alt_labeling), a.association(:hidden_labeling)]}
  l.compound_forms {|a| [a.association(:compound_form), a.association(:compound_form)]}
  l.reverse_compound_form_contents {|a| [a.association(:reverse_compound_form_content), a.association(:reverse_compound_form_content)]}
  l.label_relations {|a| [a.association(:qualifier), a.association(:translation)]}
  l.inflectionals {|a| [a.association(:inflectional), a.association(:inflectional)]}
  l.notes {|a| [a.association(:history_note, :owner_type => "Label"), a.association(:umt_source_note, :owner_type => "Label")]}
end

#specialized label factory
Factory.define :label_with_many_association, :parent => :label do |l|
  l.origin 'Test'
  l.language 'en'
  l.value 'Test'
  l.labelings {|a| [a.association(:pref_labeling), a.association(:alt_labeling), a.association(:hidden_labeling)]}
  l.compound_forms {|a| [a.association(:compound_form), a.association(:compound_form)]}
  l.reverse_compound_form_contents {|a| [a.association(:reverse_compound_form_content), a.association(:reverse_compound_form_content)]}
  l.label_relations {|a| [a.association(:qualifier), a.association(:translation)]}
  l.inflectionals {|a| [a.association(:inflectional), a.association(:inflectional)]}
  l.notes {|a| [a.association(:history_note, :owner_type => "Label"), a.association(:umt_source_note, :owner_type => "Label")]}
end

Factory.define :label_with_base_form, :class => Label do |l|
  l.origin "Abbaumechanismus"
  l.value "Abbaumechanismus"
  l.base_form "ABBAUMECHANISM"
  l.language "de"
  l.inflectional_code "DF"
end

Factory.define :pref_labeling do |pl|
end

Factory.define :hidden_labeling do |hl|
end

Factory.define :alt_labeling do |al|
end

#### CompoundForm stuff
Factory.define :compound_form, :class => UMT::CompoundForm do |cf|
  cf.compound_form_contents{|a| [a.association(:compound_form_content), a.association(:compound_form_content)]}
end

Factory.define :compound_form_content, :class => UMT::CompoundFormContent do |cfc|
   cfc.order 1
end

Factory.define :reverse_compound_form_content, :class => UMT::CompoundFormContent do |rcf|
end

#### LabelRelation stuff
Factory.define :homograph, :class => UMT::Homograph do |h|

end
Factory.define :qualifier, :class => UMT::Qualifier do |q|

end
Factory.define :translation, :class => UMT::Translation do |t|

end

#### Note stuff
Factory.define :note do |n|
 
end

Factory.define :history_note do |hn|
 hn.annotations {|a| [a.association(:note_annotation), a.association(:note_annotation)]}
end

Factory.define :scope_note do |sn|

end

Factory.define :editorial_note do |en|

end

Factory.define :example do |en|

end

Factory.define :definition do |d|

end

Factory.define :umt_source_note, :class => UMT::SourceNote do |usn|
 usn.value "blub"
end

Factory.define :umt_usage_note, :class => UMT::UsageNote do |un|

end

Factory.define :umt_change_note, :class => UMT::ChangeNote do |ucn|

end

Factory.define :umt_export_note, :class => UMT::ExportNote do |uen|

end

Factory.define :note_annotation do |na|
  na.sequence(:value) {|n| "annotation#{n}" }
end

#### Concept Classification stuff

Factory.define :classification do |cl|

end

#### Concept Classifiers stuff

Factory.define :classifiers do |cl|
 cl.notation "MT00"
end

#### Concept SemanticRelation stuff

Factory.define :narrower do |n|

end

Factory.define :broader do |b|

end

Factory.define :related do |r|
 
end

#### Concept Matches stuff
Factory.define :close_match do |cm|

end

Factory.define :broader_match do |bm|

end

Factory.define :narrower_match do |nm|

end

Factory.define :related_match do |rm|

end

Factory.define :exact_match do |em|

end

#### Inflectionals stuff
Factory.define :inflectional do  |i|
  i.value "blub"
end

#### Authentication stuff
Factory.define :user do |u|
  u.forename 'Test'
  u.surname 'User'
  u.email 'testuser@iqvoc.local'
  u.password 'omgomgomg'
  u.password_confirmation 'omgomgomg'
  u.role 'reader'
  u.active true
end