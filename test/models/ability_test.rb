require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

# The read rules have a block (single objects) and a scope (accessible_by).
# Both must agree, otherwise SQL-filtered search results differ from the
# per-object check.
class AbilityTest < ActiveSupport::TestCase
  ROLES = [nil, 'reader', 'editor', 'publisher', 'administrator'].freeze

  def ability_for(role)
    user = role && User.new(role: role)
    Ability.new(user)
  end

  setup do
    @published = Concept::Skos::Base.create!(origin: 'ability_published', published_at: Time.now)
    @draft = Concept::Skos::Base.create!(origin: 'ability_draft', published_at: nil)
  end

  test 'accessible_by agrees with can? for concepts' do
    ROLES.each do |role|
      ability = ability_for(role)
      accessible = Concept::Base.accessible_by(ability, :read).pluck(:id)

      [@published, @draft].each do |concept|
        assert_equal ability.can?(:read, concept), accessible.include?(concept.id),
                     "role #{role.inspect}, concept #{concept.origin}"
      end
    end
  end

  test 'anonymous users only read published concepts' do
    accessible = Concept::Base.accessible_by(ability_for(nil), :read)

    assert_includes accessible, @published
    refute_includes accessible, @draft
  end

  test 'users with a role read drafts' do
    %w[reader editor publisher administrator].each do |role|
      assert_includes Concept::Base.accessible_by(ability_for(role), :read), @draft, role
    end
  end

  test 'accessible_by agrees with can? for collections' do
    published = Collection::Skos::Unordered.create!(origin: 'ability_coll_published', published_at: Time.now)
    draft = Collection::Skos::Unordered.create!(origin: 'ability_coll_draft', published_at: nil)

    ROLES.each do |role|
      ability = ability_for(role)
      accessible = Collection::Base.accessible_by(ability, :read).pluck(:id)

      [published, draft].each do |collection|
        assert_equal ability.can?(:read, collection), accessible.include?(collection.id),
                     "role #{role.inspect}, collection #{collection.origin}"
      end
    end
  end

  test 'labels are readable for everybody' do
    ROLES.each do |role|
      assert ability_for(role).can?(:read, Label::Base.new), role.inspect
    end
  end
end
