require 'test_helper'

class CollectionCircularityTest < ActionDispatch::IntegrationTest
  @@klass = Iqvoc::Collection.base_class

  setup do
    # create a user
    password = "FooBar"
    user = User.new(:forename => "John", :surname => "Doe",
        :email => "foo@example.org",
        :password => password, :password_confirmation => password,
        :active => true, :role => "administrator")
    user.save

    auth = Base64::encode64("%s:%s" % [user.email, user.password])
    @env = { "HTTP_AUTHORIZATION" => "Basic " + auth }
  end

  test "circular sub-collection references are rejected during update" do
    coll1 = @@klass.new
    coll1.save
    coll2 = @@klass.new
    coll2.save

    # add coll2 as subcollection of coll1
    uri = collection_path(:id => coll1.origin, :lang => "de", :format => "html")
    params = { "concept[inline_member_collection_origins]" => "%s," % coll2.origin }
    put_via_redirect uri, params, @env

    assert_response :success
    assert_equal 1, @@klass.by_origin(coll1.origin).first.subcollections.count

    # add coll1 as subcollection of coll2
    uri = collection_path(:id => coll2.origin, :lang => "de", :format => "html")
    params = { "concept[inline_member_collection_origins]" => coll1.origin }
    put_via_redirect uri, params, @env

    assert_response :success
    assert_equal 0, @@klass.by_origin(coll2.origin).first.subcollections.count
    assert_equal flash[:error], I18n.t("txt.controllers.collections.circular_error") % coll1.label
  end
end
