class Note::SKOS::Definition < Note::SKOS::Base

  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    500 # Show near the end of the section
  end
  
  def self.search_result_partial_name
    'partials/note/skos/definition/search_result'
  end

end
