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

require 'concerns/dataset_initialization'

class SearchResultsController < ApplicationController
  include DatasetInitialization

  resource_description do
    name 'Search'
  end

  api :GET, 'search', 'Search for concepts or collections based on various criteria.'
  formats [:html, :ttl, :rdf]
  param :q, String, :required => true,
      :desc => 'Query term (URL-encoded, if necessary). Wild cards are not '\
               'supported, see the `qt` parameter below.'
  param :qt, ['exact', 'contains', 'begins_with', 'ends_with'],
      :desc => 'Query type'
  param :t, %w(labels pref_labels notes),
      :required => true,
      :desc => 'Specifies the properties to be searched.'
  param :for, %w(concept collection all),
      :desc => 'The result type you are searching for.'
  param 'l[]', Iqvoc.all_languages,
      :required => true,
      :desc => 'One or more languages of the labels or notes to be queried. '\
               'Use 2-letter language codes from ISO 639.1.'
  param :c, String,
      :desc => 'Constrains results to members of the given collection ID.'
  param 'ds[]', String ,
      :desc => 'Specifies one or more external data sets (connected thesauri)'\
               'to include in search.'
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
    # TODO: requires a dedicated :search permission because this covers more
    # than just concepts

    self.class.prepare_basic_variables(self)

    # Map short params to their log representation
    { :t  => :type,
      :q  => :query,
      :l  => :languages,
      :qt => :query_type,
      :c  => :collection_origin,
      :ds  => :datasets }.each do |short, long|
      params[long] ||= params[short]
    end

    # Select first type by default
    params[:type] = Iqvoc.searchable_classes.first.name.parameterize unless params[:type]

    # Delete parameters which should not be included into generated urls (e.g.
    # in rdf views)
    request.query_parameters.delete("commit")
    request.query_parameters.delete("utf8")

    @datasets = init_datasets

    @remote_result_collections = []

    if params[:query]
      # Deal with language parameter patterns
      languages = []
      # Either "l[]=de&l[]=en" as well as "l=de,en" should be possible
      if params[:languages].respond_to?(:each) && params[:languages].include?("none")
        # Special treatment for the "nil language"
        languages << nil
      elsif params[:languages].respond_to?(:split)
        languages = params[:languages].split(",")
      end

      # Ensure a valid class was selected
      unless klass = Iqvoc.searchable_class_names.detect {|key, value| value == params[:type] }.try(:first)
        raise "'#{params[:type]}' is not a searchable class! Must be one of " + Iqvoc.searchable_class_names.keys.join(', ')
      end
      klass = klass.constantize

      query_size = params[:query].split(/\r\n/).size

      if klass.forces_multi_query? || (klass.supports_multi_query? && query_size > 1)
        @multi_query = true
        @results = klass.multi_query(params.merge({:languages => languages}))
        # TODO: Add a worst case limit here; e.g. when on page 2 (per_page == 50)
        # each sub-query has to return 100 objects at most.
        @klass = klass
      else
        @multi_query = false
        @results = klass.single_query(params.merge({:languages => languages}))
      end

      if @multi_query
        @results = Kaminari.paginate_array(@results)
        logger.debug("Using multi query mode")
      else
        logger.debug("Using single query mode")
      end

      if params[:limit] && Iqvoc.unlimited_search_results
        @results = @results.per(params[:limit].to_i)
      end

      @results = SearchResultCollection.new(@results)

      if params[:datasets] && datasets = @datasets.select {|a| params[:datasets].include?(a.name) }
        datasets.each do |dataset|
          results = dataset.search(params)
          if results
            @results = @results + results
          else
            flash.now[:error] ||= []
            flash.now[:error] << t('txt.controllers.search_results.remote_source_error', :source => dataset)
          end
        end
      end

      @results = @results.sort {|x, y| x.to_s <=> y.to_s }
      @results = Kaminari.paginate_array(@results)
      @results = @results.page(params[:page])

      respond_to do |format|
        format.html { render :index, :layout => with_layout? }
        format.any(:ttl, :rdf) do
          # binding.pry
        end
      end
    end
  end

  def self.prepare_basic_variables(controller)
    langs = Iqvoc.all_languages.each_with_object({}) do |lang, hsh|
      lang ||= "none"
      hsh[lang] = I18n.t("languages.#{lang}", :default => lang)
    end
    controller.instance_variable_set(:@available_languages, langs)

    collections = Iqvoc::Collection.base_class.includes(:pref_labels).load
    controller.instance_variable_set(:@collections, collections)
  end

end
