namespaced_app_name = app_path.gsub("_", "/").camelize

gem 'iqvoc'

["config/application.rb",
 "config/environment.rb",
 "config/initializers/secret_token.rb",
 "config/initializers/session_store.rb",
 "config.ru",
 "Rakefile"].each do |file|
  gsub_file file, app_const_base, namespaced_app_name
end

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
# Iqvoc.default_rdf_namespace_helper_methods << :my_namespace

# Iqvoc.core_assets += []
EOF

remove_file "public/index.html"
remove_file "app/controllers/application_controller.rb"
remove_file "app/helpers/application_helper.rb"
remove_file "app/views/layouts/application.html.erb"
