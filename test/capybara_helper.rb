require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end
