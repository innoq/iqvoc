Factory.define :concept, :class => Iqvoc::Concept.base_class do |c|
  c.sequence(:origin) { |n| "_000000#{n}" }
  c.published_at 3.days.ago
  c.labelings { |labelings| [labelings.association(:pref_labeling)] }
end

Factory.define :concept_with_associations, :parent => :concept do |c|

end

Factory.define :pref_labeling, :class => Iqvoc::Concept.pref_labeling_class do |lab|
  lab.target { |target| target.association(:pref_label) }
end

Factory.define :pref_label, :class => Iqvoc::Concept.pref_labeling_class.label_class do |l|
  l.language Iqvoc::Concept.pref_labeling_languages.first
  l.value 'Tree'
  l.origin 'Tree'
end

Factory.define :xllabel, :class => Iqvoc::XLLabel.base_class do |l|
  l.origin 'Forest'
  l.language 'en'
  l.value 'Forest'
end

Factory.define :xllabel_with_association, :parent => :xllabel do |l|
end

Factory.define :user do |u|
  u.forename 'Test'
  u.surname 'User'
  u.email 'testuser@iqvoc.local'
  u.password 'omgomgomg'
  u.password_confirmation 'omgomgomg'
  u.role 'reader'
  u.active true
end
