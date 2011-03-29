require 'test_helper'

class LabelsOrderTest < ActionDispatch::IntegrationTest

  test "label order is not case-sensitive" do
    names = ["aaa", "bbb", "abc", "ABC"]
    lang = "en"
    # create a few labels
    label_class = Iqvoc::Concept.labeling_classes.first.first.label_class
    names.each { |name|
      label = label_class.new(:origin => "_%s" % name, :value => name,
        :language => lang, :published_at => Time.now)
      label.save
    }
    assert_equal names.length, Label::Base.all.count # just to avoid confusion

    get labels_path(:lang => lang, :format => "json")
    data = JSON.parse(@response.body)

    assert_response :success
    assert_equal "aaa", data[0]["name"]
    assert_equal "abc", data[1]["name"]
    assert_equal "ABC", data[2]["name"] # XXX: do we care about order of "ABC" vs. "abc"?
    assert_equal "bbb", data[3]["name"]
  end

end
