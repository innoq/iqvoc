class Note::SKOS::ChangeNote < Note::SKOS::Base

  self.rdf_predicate = 'changeNote'

  def self.edit_partial_name(obj)
    "partials/note/skos/edit_change_note"
  end
  
end
