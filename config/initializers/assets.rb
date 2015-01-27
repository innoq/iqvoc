Rails.application.config.assets.paths << 'vendor/assets/bower_components'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += Iqvoc.core_assets
