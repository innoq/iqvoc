Factory.define :concept, :class => Concept::Base do |c|
  c.sequence(:origin) { |n| "_000000#{n}" }
  c.published_at 3.days.ago
end

Factory.define :concept_with_associations, :parent => :concept do |c|
end

Factory.define :label, :class => Label::SKOSXL::Base do |l|
  l.origin 'Forest'
  l.language 'en'
  l.value 'Forest'
end

Factory.define :label_with_association, :parent => :label do |l|
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
