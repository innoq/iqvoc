# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

module My
  class RdfPredicateClass
    include ActsAsRdfPredicate
    acts_as_rdf_predicate 'skos:foo'
  end

  class RdfClassClass
    include ActsAsRdfClass
    acts_as_rdf_class 'ex:Bar'
  end

  class RdfClassSubclass < RdfClassClass
  end
end

class ActsAsRdfThingTest < ActiveSupport::TestCase
  setup do
    @predicate = My::RdfPredicateClass.new
    @object    = My::RdfClassClass.new
  end

  test 'should allow querying for rdf type' do
    assert @predicate.implements_rdf?('skos:foo')
    assert !@predicate.implements_rdf?('skos:bar')

    assert @object.implements_rdf?('ex:Bar')
    assert !@object.implements_rdf?('ex:bar')
  end

  test 'should set rdf_namespace and rdf_class or rdf_predicate' do
    assert_equal 'skos', My::RdfPredicateClass.rdf_namespace
    assert_equal 'foo',  My::RdfPredicateClass.rdf_predicate

    assert_equal 'ex',  My::RdfClassClass.rdf_namespace
    assert_equal 'Bar', My::RdfClassClass.rdf_class
  end

  test 'setting rdf class for subclass does not affect parent class' do
    My::RdfClassSubclass.acts_as_rdf_class 'skos:Blah'
    assert_equal 'Blah', My::RdfClassSubclass.rdf_class
    assert_equal 'Bar',  My::RdfClassClass.rdf_class
  end

end
