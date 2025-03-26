class AdaptZeitwerkSkosNamingToInstanceConfiguration < ActiveRecord::Migration[7.1]
  def up
    execute "UPDATE configuration_settings SET key = REGEXP_REPLACE(key, '::SKOS::', '::Skos::', 'g') WHERE key LIKE '%::SKOS::%';"
    execute "UPDATE configuration_settings SET key = REGEXP_REPLACE(key, '::SKOSXL::', '::Skosxl::', 'g') WHERE key LIKE '%::SKOSXL::%';"
  end

  def down
    execute "UPDATE configuration_settings SET key = REGEXP_REPLACE(key, '::Skos::', '::SKOS::', 'g') WHERE key LIKE '%::Skos::%';"
    execute "UPDATE configuration_settings SET key = REGEXP_REPLACE(key, '::Skosxl::', '::SKOSXL::', 'g') WHERE key LIKE '%::Skosxl::%';"
  end
end
