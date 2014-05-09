namespaced_app_name = app_path.gsub("_", "/").camelize

gem 'iqvoc'

["config/application.rb",
 "config/environment.rb",
 "config/initializers/session_store.rb",
 "config.ru",
 "Rakefile"].each do |file|
  gsub_file file, app_const_base, namespaced_app_name
end

gsub_file "config/application.rb", /filter_parameters .*:password\b/,
    '\0, :password_confirmation'

gsub_file "config/routes.rb", "#{app_const_base}::Application", "Rails.application"

%w(development test production).each do |env|
  remove_file "config/environments/#{env}.rb"
  create_file "config/environments/#{env}.rb", <<-EOF
require 'iqvoc/environments/#{env}'

if #{namespaced_app_name}.const_defined?(:Application)
  #{namespaced_app_name}::Application.configure do
    # Settings specified here will take precedence over those in config/environment.rb
    Iqvoc::Environments.setup_#{env}(config)
  end
end
EOF
end

initializer 'iqvoc.rb', <<-EOF
Iqvoc.config do |config|
  config.register_settings({
    "title" => "#{app_const_base.titleize}"
  })
end

# Iqvoc::Concept.base_class_name = "MyConceptClass"
# Iqvoc::Concept.pref_labeling_class_name = "MyLabelingClass"
# Iqvoc::Concept.further_relation_class_names << "MyConceptRelationClass"
# Iqvoc::Concept.note_class_names = []
# Iqvoc.default_rdf_namespace_helper_modules << MyModule

# Iqvoc.core_assets += []
EOF

remove_file "app/assets/javascripts/application.js"
create_file "app/assets/javascripts/manifest.js", <<-EOF
//= require framework
//= require iqvoc/manifest

//= require #{app_path}/manifest
EOF
create_file "app/assets/javascripts/#{app_path}/manifest.js"

remove_file "app/assets/stylesheets/application.css"
create_file "app/assets/stylesheets/manifest.css", <<-EOF
/*
*= require framework
*= require iqvoc/manifest

*= require #{app_path}/manifest
*/
EOF
create_file "app/assets/stylesheets/#{app_path}/manifest.css"

remove_file "public/index.html"
remove_file "app/controllers/application_controller.rb"
remove_file "app/helpers/application_helper.rb"
remove_file "app/views/layouts/application.html.erb"

remove_file "Gemfile"
create_file "Gemfile", "source 'http://rubygems.org'\n\ngem 'iqvoc'"
