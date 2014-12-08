# Validations for both concepts and labels

module FirstLevelObjectValidations
  extend ActiveSupport::Concern

  included do
    validate :distinct_versions, on: :create # FIXME: on: :create?
    validate :origin_has_to_be_escaped
  end

  def origin_has_to_be_escaped
    unless Iqvoc::Origin.new(origin).valid?
      errors.add :origin, I18n.t('txt.models.concept.origin_error')
    end
  end

  def distinct_versions
    query = self.class.by_origin(origin)
    existing_total = query.count
    if existing_total >= 2
      errors.add :base, I18n.t('txt.models.concept.version_error', origin: origin)
    elsif existing_total == 1
      unless (query.published.count == 0 and published?) or
             (query.published.count == 1 and not published?)
        errors.add :base, I18n.t('txt.models.concept.version_error', origin: origin)
      end
    end
  end
end
