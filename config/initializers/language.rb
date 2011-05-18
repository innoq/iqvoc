# Set the default locale to the first configured PrefLabeling language
Rails.application.config.i18n.default_locale = Iqvoc::Concept.pref_labeling_languages.first

# # Turn on i18n fallback feature
# require "i18n/backend/fallbacks"
# I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
