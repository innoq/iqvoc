require File.dirname(__FILE__) + '/../test_helper'

class SemanticRelationTest < ActiveSupport::TestCase
#  fixtures :concepts, :semantic_relations
#
#  def setup
#    @tree   = concepts(:tree)
#    @branch = concepts(:branch)
#    @forest = concepts(:forest)
#  end
#
#  def test_broader_relation_created_only_once
#    assert_equal [@forest.id], @tree.broader_ids
#    assert Broader.new(:owner => @tree, :target => @branch).valid?
#    @tree.broader << @branch
#    assert_equal [@forest.id, @branch.id], @tree.broader_ids
#    @tree.broader << @branch
#    assert_equal [@forest.id, @branch.id], @tree.broader_ids
#    assert !Broader.new(:owner => @tree, :target => @forest).valid?
#    assert !Broader.new(:owner => @tree, :target => @branch).valid?
#  end
  
end
