class OriginMapping
  def replace_umlauts(str)
    str.gsub(/Ö/, 'Oe').gsub(/Ä/, 'Ae').gsub(/Ü/, 'Ue').gsub(/ö/, 'oe').gsub(/ä/, 'ae').gsub(/ü/, 'ue').gsub(/ß/, 'ss')
  end

  def to_camelcase(str)
    str.gsub(/\s/,'_').camelize
  end

  def replace_brackets(str)
    str.gsub("[", "--").gsub("]", "").gsub("(", "--").gsub(")", "")
  end

  def replace_commas(str)
    str.gsub(',', '-')
  end
  
  def sanitize_for_base_form(str)
    str.gsub(",", "").gsub("/", "").gsub(".", "").gsub("[", "").gsub("]", "")
  end

  def merge(str)
    replace_commas(replace_umlauts(to_camelcase(replace_brackets(str))))
  end
end