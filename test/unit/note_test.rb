require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  
  def setup
  end

  test "should parse turtle note annotations" do
    str = '[umt:source <aDisBMS>; umt:thsisn "00000001"; dct:date "2010-04-29"]'
    concept = Concept::SKOS::Base.create(:origin => "_00000001", :published_at => Time.now)
    concept.note_skos_change_notes << ::Note::SKOS::ChangeNote.new.from_annotation_list!(str)
    
    assert_equal Note::SKOS::ChangeNote.count, 1
    assert_equal Note::SKOS::ChangeNote.first.annotations.count, 3
    assert_equal Note::Annotated::Base.where(:identifier => 'umt:thsisn', :value => '"00000001"').count, 1

  end
  
end
