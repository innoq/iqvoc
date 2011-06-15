# uncomment the settings below and adjust as desired
# see lib/iqvoc.rb for the full list of available setting

require Rails.root.join("lib/iqvoc")

if Rails.env != "test"

  #Iqvoc.title = "My Thesaurus"

  # custom assets
  #Iqvoc.additional_js_files  += ["vendor/myScripts.js"]
  #Iqvoc.additional_css_files += ["vendor/myStyles.css"]

  # label languages (and classes)
  #Iqvoc::Concept.pref_labeling_languages      = [ :de, :en ]
  #Iqvoc::Concept.further_labeling_class_names = {
  #  "Labeling::SKOS::AltLabel" => [ :de, :en ]
  #}

end
