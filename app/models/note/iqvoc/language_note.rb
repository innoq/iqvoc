# This class is used to assign labels to Collections. So it is no note in the
# common sense!
class Note::Iqvoc::LanguageNote < Note::SKOS::Base
  def build_rdf(document, subject)
    subject.Rdfs::label(self.value, :lang => self.language)
  end
end
