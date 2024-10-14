# FIXME: custom auto loading inflections due class naming inconsistencies with acronyms
Rails.autoloaders.main.inflector.inflect(
  'skos' => 'SKOS',
  'rdfs' => 'RDFS',
  'rdfapi' => 'RDFAPI',
  'version' => 'VERSION'
)
