class Dataset::Adaptors::Iqvoc::AlphabeticalSearchAdaptor < Dataset::Adaptors::Iqvoc::SearchAdaptor
  def search(prefix, locale)
    fetch_results("#{locale}/alphabetical_concepts/#{prefix}.html")
    @results
  end

  def fetch_results(url, params = {})
    begin
      response = @conn.get(url, params)
      @results ||= []
      @results += extract_results(response.body)
      while more = @doc.at_css('a[rel=next]')
        fetch_results(more[:href], {})
      end
    rescue Faraday::Error::ConnectionFailed,
      Faraday::Error::ResourceNotFound,
      Faraday::Error::TimeoutError => e
        Rails.logger.warn("HTTP error while querying remote source #{url}: #{e.message}")
        return nil
    end
  end

  def extract_results(html)
    @doc = Nokogiri::HTML(html)

    @doc.css('.concept-item').map do |element|
      link = element.at_css('.concept-item-link')
      label, path = link.text, link['data-resource-path'] # href

      options = {
        :definition => element.at_css('.concept-item-definition').try(:content),
        :definition_language => element.at_css('.concept-item-definition').try(:[], :lang)
      }

      result = AlphabeticalSearchResultRemote.new(url, path, label, options)
    end
  end
end
