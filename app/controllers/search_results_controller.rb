# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class SearchResultsController < ApplicationController
  include DatasetInitialization

  before_action :build_search_query, only: [:index]

  resource_description do
    name 'Search'
  end

  api :GET, 'search', 'Search for concepts or collections based on various criteria.'
  formats [:html, :ttl, :rdf]
  param :q, String, required: true,
      desc: 'Query term (URL-encoded, if necessary). Wild cards are not '\
               'supported, see the `qt` parameter below.'
  param :qt, SearchQuery::ALLOWED_QUERY_TYPES,
      desc: 'Query type'
  param :t, SearchQuery::ALLOWED_TYPES,
      required: true,
      desc: 'Specifies the properties to be searched.'
  param :for, %w(concept collection all),
      desc: 'The result type you are searching for.'
  param 'l[]', Iqvoc.all_languages,
      required: true,
      desc: 'One or more languages of the labels or notes to be queried. '\
               'Use 2-letter language codes from ISO 639.1.'
  param :c, String,
      desc: 'Constrains results to members of the given collection ID.'
  param 'ds[]', String ,
      desc: 'Specifies one or more external data sets (connected thesauri)'\
               'to include in search.'
  param :include_expired, String,
        desc: 'Specifies if expired concepts should be included (defaults to false).'
  example <<-DOC
    GET /search.ttl
    200

    # omitted namespace definitions
    <http://try.iqvoc.net/search.ttl?l=en&q=dance&t=labels> a sdc:Query;
                                                            sdc:totalResults 1;
                                                            sdc:itemsPerPage 40;
                                                            sdc:searchTerms "dance";
                                                            sdc:first <http://try.iqvoc.net/search.ttl?l=en&page=1&q=dance&t=labels>;
                                                            sdc:last <http://try.iqvoc.net/search.ttl?l=en&page=1&q=dance&t=labels>;
                                                            sdc:result search:result1.
    <http://try.iqvoc.net/search.ttl?l=en&page=1&q=dance&t=labels> a sdc:Page;
                                                                   sdc:startIndex 1.
    search:result1 a sdc:Result;
                   sdc:link :dance;
                   skos:prefLabel "Dance"@en.
  DOC

  def index
    authorize! :read, Concept::Base
    # TODO: requires a dedicated :search permission because this covers more than just concepts

    # Delete parameters which should not be included into generated urls (e.g.
    # in rdf views)
    request.query_parameters.delete('commit')
    request.query_parameters.delete('utf8')

    @datasets = init_datasets

    @remote_result_collections = []

    # Legacy: views and result partials (also in other gems) still read the
    # normalized values from params
    apply_legacy_params

    return render_bad_request unless @search_query.valid?

    if @search_query.submitted?
      @results = @search_query.search_class
                              .single_query(params.merge(@search_query.to_params))
                              .filter { |search_result| result_allowed?(search_result) }

      if params[:limit] && Iqvoc.unlimited_search_results
        @results = @results.per(params[:limit].to_i)
      end

      if @search_query.datasets && (datasets = @datasets.select { |a| @search_query.datasets.include?(a.name) })
        @results = SearchResultCollection.new(@results)
        datasets.each do |dataset|
          results = dataset.search(params)
          if results
            @results = @results + results
          else
            flash.now[:error] ||= []
            flash.now[:error] << t('txt.controllers.search_results.remote_source_error', source: dataset)
          end
        end
        @results = @results.sort { |x, y| x.to_s <=> y.to_s }
      end

      @results = Kaminari.paginate_array(@results)
      @results = @results.page(params[:page])

      respond_to do |format|
        format.html {
          if request.headers['Accept'] == 'text/html; fragment=true'
            render template: 'search_results/_result_list', layout: false
          else
            prepare_form
            render :index, layout: with_layout?
          end
        }
        format.any(:ttl, :rdf, :nt)
      end
    else
      respond_to do |format|
        format.html {
          prepare_form
          render :index
        }
        format.any(:ttl, :rdf, :nt) { head :bad_request }
      end
    end
  end

  private

  def prepare_form
    @available_languages = Iqvoc.all_languages.each_with_object({}) { |lang, hsh|
      lang ||= 'none'
      hsh[lang] = I18n.t("languages.#{lang}", default: lang)
    }

    # AR requires mapping to existing object attributes so that value is mapped to the unused status attribute to keep the information
    @collections = Iqvoc::Collection.base_class.joins(:pref_labels).order('value').select('value AS status, concepts.origin')
  end

  def build_search_query
    @search_query = SearchQuery.from_url_params(params)
  end

  # Legacy: views and result partials (also in other gems) still read the
  # normalized values from params (short names).
  def apply_legacy_params
    params.merge!(@search_query.to_url_params)
  end

  def render_bad_request
    Rails.logger.warn("Invalid search query: #{@search_query.errors.full_messages.to_sentence}")
    respond_to do |format|
      format.html {
        prepare_form
        render :index, status: :bad_request
      }
      format.any { head :bad_request }
    end
  end

  def result_allowed?(result)
    if result.result_object.is_a?(Labeling::Base)
      can?(:read, result.owner)
    else
      can?(:read, result.result_object)
    end
  end

end
