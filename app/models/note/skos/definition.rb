class Note::SKOS::Definition < Note::SKOS::Base

  def self.view_section
    "main"
  end

  def self.view_section_sort_key
    500 # Show near the end of the section
  end

end
