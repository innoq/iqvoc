class OriginMapping
  
    def self.replace_umlauts(str)
      str.gsub(/Ö/, 'Oe').
          gsub(/Ä/, 'Ae').
          gsub(/Ü/, 'Ue').
          gsub(/ö/, 'oe').
          gsub(/ä/, 'ae').
          gsub(/ü/, 'ue').
          gsub(/ß/, 'ss')
    end

    def self.replace_whitespace(str)
      str.gsub(/\s/,'_').camelize
    end

    def self.replace_special_chars(str)
      str.gsub("[", "--").gsub("]", "").gsub("(", "--").gsub(")", "").gsub(',', '-').gsub('/', '-')
    end
  
    def self.sanitize_for_base_form(str)
      # str.gsub(/[,\/\.\[\]]/, '')
      str.gsub(",", "").gsub("/", "").gsub(".", "").gsub("[", "").gsub("]", "")
    end

    def self.merge(str)
      replace_umlauts(replace_whitespace(replace_special_chars(str)))
    end

end