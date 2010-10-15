class Note::SKOS::ChangeNote < Note::SKOS::Base

  def self.edit_partial_name(obj)
    "partials/note/skos/edit_change_note"
  end
  
  def self.searchable?
    false
  end

end
