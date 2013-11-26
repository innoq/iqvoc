class Dataset::Adaptors::Iqvoc::LabelAdaptor < Dataset::Adaptors::Iqvoc::HTTPAdaptor
  def find(concept_url)
    path = URI.parse(concept_url).path
    if response = http_get(path)
      extract_label(response.body)
    end
  end

  def extract_label(html)
    doc = Nokogiri::HTML(html)
    node = doc.at_css('h1')
    node.at_css('small').remove
    node.text.try(:strip)
  end
end
