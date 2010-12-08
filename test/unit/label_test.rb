require 'test_helper'

class LabelTest < ActiveSupport::TestCase
  
  def setup
    @current_label = Factory.create(:xllabel_with_association)
    @user = Factory.create(:user)
  end

  def test_should_not_create_more_than_two_versions_of_a_label
    first_new_label = Label::SKOSXL::Base.new(@current_label.attributes)
    second_new_label = Label::SKOSXL::Base.new(@current_label.attributes)
    assert first_new_label.save
    assert_equal second_new_label.save, false
  end
  
end
