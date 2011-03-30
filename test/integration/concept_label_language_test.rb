require 'test_helper'

class ConceptLabelLanguageTest < ActionDispatch::IntegrationTest

  setup do
    # ensure we're in SKOS-XL mode -- XXX: side-effects!
    #Iqvoc::Concept.pref_labeling_class_name = "Labeling::SKOSXL::PrefLabel"
    #Iqvoc::Concept.pref_labeling_languages = [:de]
    #Iqvoc::Concept.further_labeling_class_names = {
    #  "Labeling::SKOSXL::AltLabel" => [:de, :en]
    #}

    # create a few XL labels
    names = {
      "English" => "en",
      "Deutsch" => "de"
    }
    names.each { |name, lang|
      label = Iqvoc::XLLabel.base_class.new(:origin => name, :value => name,
          :language => lang, :published_at => Time.now)
      label.save
    }
    # create a user
    password = "FooBar"
    user = User.new(:forename => "John", :surname => "Doe",
        :email => "foo@example.org",
        :password => password, :password_confirmation => password,
        :active => true, :role => "administrator")
    user.save
    # confirm environment, just to be safe
    assert_equal names.size, Label::Base.all.count
    assert_equal 0, Concept::Base.all.count
    assert_equal 1, User.all.count

    auth = Base64::encode64("%s:%s" % [user.email, user.password])
    @env = { "HTTP_AUTHORIZATION" => "Basic " + auth }
  end

  test "invalid alt label languages are rejected" do # XXX: insufficiently descriptive
    uri = concepts_path(:lang => "de", :format => "html")
    # NB: label language does not match relation language
    params = { "concept[inline_labeling_skosxl_alt_labels_en]" => "Deutsch" }
    post_via_redirect uri, params, @env

    assert_response :success
    assert_equal 1, Concept::Base.all.count
    assert_equal 0, Concept::Base.first.labels.count
    # reset -- XXX: not very elegant
    Concept::Base.first.destroy
    assert_equal 0, Concept::Base.all.count
  end

  test "invalid pref label languages are rejected" do # XXX: insufficiently descriptive
    uri = concepts_path(:lang => "de", :format => "html")
    # NB: label language does not match relation language
    params = { "concept[inline_labeling_skosxl_pref_labels_de]" => "English" }
    post_via_redirect uri, params, @env

    assert_response :success
    assert_equal 1, Concept::Base.all.count
    assert_equal 0, Concept::Base.first.labels.count
  end
end
