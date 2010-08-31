# <?xml version="1.0"?>
# <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
#   <skos:Concept rdf:about="http://www.eionet.eu.int/gemet/concept/7">
#     <owl:sameAs rdf:resource="http://www.eionet.europa.eu/gemet/concept/4109" />
#     <skos:prefLabel xml:lang="en">abandoned site</skos:prefLabel>
#     <skos:prefLabel xml:lang="de">Altstandort</skos:prefLabel>
#     <!-- skos:inScheme lassen wir weg -->
#     <skos:definition xml:lang="en">
#       Site that cannot be used for any purpose, being contaminated by pollutants, not necessarily radioactive.
#       (Source: RRDA)
#     </skos:definition>
#     <skos:related rdf:resource="http://www.example.com/AAT/concepts#300021155"/>
#     <skos:broader rdf:resource="http://www.eionet.eu.int/gemet/concept/4666"/>
#     <skos:narrower rdf:resource="http://www.eionet.eu.int/gemet/concept/2275"/>
#   </skos:Concept>
# </rdf:RDF>

xml.instruct!
xml.rdf :RDF, RdfHelpers.to_xml_attribute_array do
  xml.skos :Concept, {'rdf:about' => concept_non_informational_resource_url(@concept)} do
    xml.owl :sameAs, {'rdf:resource' => "http://www.eionet.europa.eu/gemet/concept/#{@concept.origin}"}
    @concept.pref_labels.each do |label|
      xml.skos :prefLabel, label.value, {'xml:lang' => label.language}
    end
    @concept.definitions.each do |definition|
        xml.skos :definition, definition.value, {'xml:lang' => definition.language}
    end
    @concept.semantic_relations.each do |rel|
      rel_name = rel.class.to_s.downcase
      if ["broader", "narrower", "related"].include? rel_name
        xml.skos rel_name.to_sym, {'rdf:resource' => concept_non_informational_resource_url(rel.target)}
      end
    end
  end
end