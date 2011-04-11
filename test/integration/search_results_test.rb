require 'test_helper'
require 'integration_test_helper'


class SearchTest < ActionDispatch::IntegrationTest

  setup do
    # create a few XL labels
    labels = {}
    {
      "terra" => "la",
      "earth" => "en",
      "Erde" => "de",
      "sol" => "la",
      "sun" => "en",
      "Sonne" => "de",
      "inhabited" => "en",
      "bewohnt" => "de",
      "uninhabited" => "en",
      "unbewohnt" => "de"
    }.map { |name, lang|
      label = Factory.create(:xllabel, :origin => "_%s" % name,
          :language => lang, :value => name, :published_at => Time.now)
      labels[name] = label
    }

    # create a few concepts
    [
      ["Erde", "earth"],
      ["Sonne", "sun"]
    ].each { |pref, alt|
        concept = Factory.create(:concept, :origin => "_%s" % pref,
            :labelings => [], :narrower_relations => [], # avoid creating additional concepts/label[ing]s
            :published_at => Time.now)
        Factory.create(:pref_labeling, :owner => concept, :target => labels[pref])
        Factory.create(:alt_labeling, :owner => concept, :target => labels[alt])
    }

    # create a few collections
    [
      ["bewohnt", "inhabited"],
      ["unbewohnt", "uninhabited"]
    ].each { |pref, alt|
        collection = Factory.create(:collection)
        Factory.create(:pref_labeling, :owner => collection, :target => labels[pref])
        Factory.create(:alt_labeling, :owner => collection, :target => labels[alt])
    }

    # confirm environment, just to be safe (i.e. ensure that factories,
    # for example, don't introduce unexpected side-effects)
    assert_equal 10, Label::Base.all.count
    assert_equal 8, Labeling::Base.all.count
    assert_equal 2, Iqvoc::Concept.base_class.all.count
    assert_equal 2, Iqvoc::Collection.base_class.all.count
    assert_equal 4, Concept::Base.all.count
  end

  test "HTML search returns matches" do
    uri = search_path(:lang => "de", :format => "html")
    uri += "?l[]=de&l[]=en" # doesn't fit into params hash
    params = {
      "q" => "Erde",
      "qt" => "exact", # match type
      "t" => "all", # search type
      "c" => "" # collection
    }
    params.each { |key, value|
      uri += "&%s=%s" % [key, value] # XXX: hacky and brittle (e.g. lack of URL-encoding)
    }

    visit uri

    assert page.has_css?("#search_results dt", :count => 1)
  end

  test "RDF search returns matches" do
    uri = search_path(:lang => "de", :format => "rdf")
    uri += "?l[]=de&l[]=en" # doesn't fit into params hash
    params = {
      "q" => "Erde",
      "qt" => "exact", # match type
      "t" => "all", # search type
      "c" => "" # collection
    }
    get uri, params

    assert_match /<sdc:result rdf:resource.*#result1"\/>/, @response.body
    assert_no_match /#result2"\/>/, @response.body
  end
end
