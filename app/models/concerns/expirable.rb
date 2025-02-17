module Expirable
  extend ActiveSupport::Concern

  included do
    def self.expired(time = Time.now)
      where(arel_table[:expired_at].lteq(time))
    end

    def self.not_expired(time = Time.now)
      col = arel_table[:expired_at]
      where((col.eq(nil)).or(col.gt(time)))
    end
  end
end
