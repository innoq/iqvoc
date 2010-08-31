module LabelsHelper
  def options_for_inflectional_code(label)
    collection = "<option value=\"\" data-endings=\"\"></option>"
    Inflectional.mappings_for_language(label.language).map.each do |e|
      selected    = " selected=\"selected\"" if e.first.to_s == label.inflectional_code
      endings = e.last.map{|e| e.downcase }.join(" ")
      collection += "<option value=\"#{e.first}\"#{selected} data-endings=\"#{endings}\">#{e.first} (#{endings})</option>"
    end
    collection
  end
  
  def part_of_speech(code)
    part_of_speech_mappings[code]
  end
  
  def part_of_speech_mappings
    return @mappings if @mappings
    @mappings = {}
    part_of_speech_options.each do |item|
      @mappings[item.last] = item.first
    end
    @mappings
  end
  
  def part_of_speech_options
    [
      [ I18n.t("txt.part_of_speech.plural_form")    , "0" ],
      [ I18n.t("txt.part_of_speech.adjective")      , "1" ],
      [ I18n.t("txt.part_of_speech.proper_name")    , "2" ],
      [ I18n.t("txt.part_of_speech.numeral")        , "3" ],
      [ I18n.t("txt.part_of_speech.pronoun")        , "4" ],
      [ I18n.t("txt.part_of_speech.abbreviation")   , "5" ],
      [ I18n.t("txt.part_of_speech.verb")           , "6" ],
      [ I18n.t("txt.part_of_speech.noun.male")      , "7" ],
      [ I18n.t("txt.part_of_speech.noun.female")    , "8" ],
      [ I18n.t("txt.part_of_speech.noun.neuter")    , "9" ],
      [ I18n.t("txt.part_of_speech.name_authority") , "N" ],
    ]
  end
end
