# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
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
  skip_before_filter :require_user

  def index
    authorize! :read, Concept::Base # TODO: I think a :search right would be
    # better here because you're able to serach more than only concepts.

    self.class.prepare_basic_variables(self)

    # Map short params to their log representation
    {:t => :type, :q => :query, :l => :languages, :qt => :query_type, :c => :collection_origin}.each do |short, long|
      params[long] ||= params[short]
    end

    # Select first type by default
    params[:type] = Iqvoc.searchable_class_names.first.parameterize unless params[:type]

    # Delete parameters which should not be included into generated urls (e.g.
    # in rdf views)
    request.query_parameters.delete("commit")
    request.query_parameters.delete("utf8")

    if params[:query]
      if params[:query].blank? && params[:collection_origin].blank?
        flash.now[:error] = I18n.t('txt.controllers.search_results.insufficient_data')
        render :action => 'index', :status => 422
        return
      end

      # Special treatment for the "nil language"
      params[:languages] << nil if params[:languages].is_a?(Array) && params[:languages].include?("none")

      # Ensure a valid class was selected
      unless type_class_index = Iqvoc.searchable_class_names.map(&:parameterize).index(params[:type].parameterize)
        raise "'#{params[:type]}' is not a valid / configured searchable class! Must be one of " + Iqvoc.searchable_class_names.join(', ')
      end
      klass = Iqvoc.searchable_class_names[type_class_index].constantize

      query_size = params[:query].split(/\r\n/).size

      if klass.forces_multi_query? || (klass.supports_multi_query? && query_size > 1)
        @multi_query = true
        @results = klass.multi_query(params)
        # TODO: Add a worst case limit here; e.g. when on page 2 (per_page == 50)
        # each sub-query has to return 100 objects at most.
        @klass = klass
      else
        @multi_query = false
        @results = klass.single_query(params)
      end

      if @multi_query
        @results = Kaminari.paginate_array(@results)
        logger.debug("Using multi query mode")
      else
        logger.debug("Using single query mode")
      end

      @results = @results.page(params[:page])

      if params[:limit] and Iqvoc.unlimited_search_results
        @results = @results.per(params[:limit].to_i)
      end

      respond_to do |format|
        format.html
        format.ttl { render('search_results/index.iqrdf') }
        format.rdf { render('search_results/index.iqrdf') }
      end

    end
  end

  def self.prepare_basic_variables(controller)
    label_langs = Iqvoc::Concept.labeling_class_names.values.flatten.map(&:to_s)
    langs = (Iqvoc.available_languages + label_langs).uniq.each_with_object({}) do |lang, hsh|
      lang ||= "none"
      hsh[lang] = I18n.t("languages.#{lang}", :default => lang)
    end
    controller.instance_variable_set(:@available_languages, langs)

    collections = Iqvoc::Collection.base_class.includes(:pref_labels).all
    controller.instance_variable_set(:@collections, collections)
  end

end
