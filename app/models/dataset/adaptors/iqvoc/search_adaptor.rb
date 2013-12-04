class Dataset::Adaptors::Iqvoc::SearchAdaptor < Dataset::Adaptors::Iqvoc::HTTPAdaptor
  def search(raw_params = {})
    languages = raw_params.fetch(:languages, I18n.locale)
    languages = Array.wrap(languages).flatten.join(",")

    params = {
      :q => raw_params[:q],
      :t => raw_params[:t],
      :l => languages,
      :c => raw_params[:c],
      :qt => raw_params[:qt],
      :page => 1 # hard code the first page as we need to follow pagination links
    }

    fetch_results('/search.html', params)
    @results
  end

  def fetch_results(path, params = {})
    begin
      response = @conn.get(path, params)
      @results ||= []
      @results += extract_results(response.body)
      while more = @doc.at_css('a[rel=next]')
        fetch_results(more[:href], {})
      end
    rescue Faraday::Error::ConnectionFailed,
      Faraday::Error::ResourceNotFound,
      Faraday::Error::TimeoutError => e
        Rails.logger.warn("HTTP error while querying remote source #{path}: #{e.message}")
        return nil
    end
  end

  def extract_results(html)
    @doc = Nokogiri::HTML(html)

    @doc.css('.search-result').map do |element|
      link = element.at_css('.search-result-link')
      label, path = link.text, link['data-resource-path']
      result = SearchResultRemote.new(url, path, label)

      if (meta = element.css('.search-result-meta > .search-result-value')) && meta.any?
        meta.each do |element|
          result.add_meta_information(element['data-key'], element.text)
        end
      end

      if body = element.at_css('.search-result-body')
        result.body = body.text
      end

      result.rdf_namespace = element['data-rdf-namespace']
      result.rdf_predicate = element['data-rdf-predicate']
      result.language = element['data-rdf-language']

      result
    end
  end
end
