# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')
require 'capybara/rails'
require 'test/unit/failure'
require 'test/unit/error'
require 'fileutils'

module ActionController
  class IntegrationTest
    include Capybara::DSL

    Capybara.javascript_driver = :webkit

    CAPYBARA_SNAPSHOTS_DIR = Rails.root.join("tmp", "capybara_snapshots")
    FileUtils.rm_rf CAPYBARA_SNAPSHOTS_DIR
    FileUtils.mkdir_p CAPYBARA_SNAPSHOTS_DIR

    def login(role = nil)
      logout
      user(role)
      visit new_user_session_path(:lang => :de)
      fill_in "E-Mail", :with => user.email
      fill_in "Passwort", :with => user.password
      click_button "Anmelden"
    end

    def logout
      visit dashboard_path(:lang => :de)
      click_link_or_button "Abmelden" if page.has_link?("Abmelden")
      @user.try(:destroy)
      @user = nil
    end

    def user(role = nil)
      @user ||= FactoryGirl.create(:user, :role => (role || User.default_role))
    end

    def create_snapshot
      dbg "[SNAPSHOT]", method_name, self.class.name.underscore
      filename = "#{self.class.name.underscore}_#{method_name}.html"
      filepath = File.join(CAPYBARA_SNAPSHOTS_DIR, filename)
      dbg "[SNAPSHOT]", filename, filepath
      if File.writable?(filepath)
        dbg "[SNAPSHOT] writeable", true
        File.open(filepath, "w") do |f|
          f.write page.body
        end
      else File.writable?(filepath)
        dbg "[SNAPSHOT] writeable", false
      end
    end

  end
end

module Test
  module Unit

    module FailureHandler

      def add_failure_with_snapshot(*args)
        dbg "[FAILURE]", method_name, method(:create_snapshot)
        create_snapshot
        add_failure_without_snapshot(*args)
      end
      alias_method_chain :add_failure, :snapshot

    end

    module ErrorHandler

      def add_error_with_snapshot(*args)
        dbg "[ERROR]", method_name, method(:create_snapshot)
        create_snapshot
        add_error_without_snapshot(*args)
      end
      alias_method_chain :add_error, :snapshot

    end

  end
end
