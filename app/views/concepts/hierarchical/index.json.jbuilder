json.array! @concepts.select { |c| can? :read, c } do |concept|
  json.id concept.id
  json.url concept_path(:id => concept, :format => :html)
  json.text CGI.escapeHTML(concept.pref_label.to_s)

  if params[:broader]
    json.hasChildren concept.broader_relations.any?
  else
    json.hasChildren concept.narrower_relations.any?
  end

  if concept.additional_info.present?
    json.additionalText " (#{concept.additional_info})"
  end
end
