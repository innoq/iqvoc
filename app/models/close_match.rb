class CloseMatch < Match
  validates_format_of :value, :with => /(^$)|^\d+$|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
end