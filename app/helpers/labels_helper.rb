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

  def render_label_association(hash, label, association_class, furter_options = {})
    ((hash[association_class.view_section(label)] ||= {})[association_class.view_section_sort_key(label)] ||= "") <<
      render(association_class.partial_name(label), furter_options.merge(:label => label, :klass => association_class))
  end

  def label_view_data(label, inflectionals_labels, compound_in)
    res = {'main' => {}, 'inflectionals' => {}, 'compound_forms' => {}}

    res['main'][10] = render 'labels/value_and_language', :label => label

    res['main'][1000] = render 'labels/details', :label => label

    res['inflectionals'][100] = render 'labels/inflectionals', :label => label, :inflectionals_labels => inflectionals_labels

    res['compound_forms'][100] = render 'labels/compound_forms', :label => label, :compound_in => compound_in

    Iqvoc::Concept.labeling_classes.keys.each do |labeling_class|
        render_label_association(res, label, labeling_class)
    end

    Iqvoc::XLLabel.relation_classes.each do |relation_class|
      render_label_association(res, label, relation_class)
    end

    Iqvoc::XLLabel.note_classes.each do |note_class|
      render_label_association(res, label, note_class)
    end

    res
  end

end
