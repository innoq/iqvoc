# encoding: UTF-8

# Copyright 2011-2025 innoQ Deutschland GmbH
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

class Collections::AlphabeticalController < CollectionsController
  include DatasetInitialization

  def index
    authorize! :read, Concept::Base

    # only initialize dataset if dataset param is set
    # prevent obsolet http request when using matches widget
    datasets = params[:dataset] ? init_datasets : []

    identify_used_first_letters

    if dataset = datasets.detect { |dataset| dataset.name == params[:dataset] }
      query = params[:prefix].mb_chars.downcase.to_s
      @search_results = dataset.alphabetical_search(query, I18n.locale) || []
      @search_results = Kaminari.paginate_array(@search_results).page(params[:page])
    else
      # When in single query mode, AR handles ALL includes to be loaded by that
      # one query. We don't want that! So let's do it manually :-)
      includes = Iqvoc::Collection.base_class.default_includes
      if Iqvoc::Collection.note_classes.include?(Note::Skos::Definition)
        includes << Note::Skos::Definition.name.to_relation_name
      end

      search_results_size = find_labelings.count
      search_results = find_labelings.page(params[:page])
      Iqvoc::Collection.pref_labeling_class.preload(search_results, owner: includes)

      @search_results = search_results.to_a.map { |pl| AlphabeticalSearchResult.new(pl) }
      @search_results = Kaminari.paginate_array(@search_results, total_count: search_results_size).page(params[:page])
    end

    respond_to do |format|
      format.html { render :index, layout: with_layout? }
    end
  end

  protected

  def identify_used_first_letters
    @letters = Label::Base.where("#{Label::Base.table_name}.language = ?", I18n.locale).joins(:pref_labeled_collections).where("concepts.published_at IS NOT NULL").where("concepts.expired_at IS NULL OR concepts.expired_at >= ?", Time.now).where("concepts.type = ?", Iqvoc::Collection.base_class_name).select("DISTINCT UPPER(SUBSTR(value, 1, 1)) AS letter").order("letter").map(&:letter)
  end

  def find_labelings
    letter = (@letters.include?('A')) ? 'a' : @letters.first
    query = (params[:prefix] || letter)&.mb_chars&.downcase.to_s

    Iqvoc::Collection.pref_labeling_class
      .collection_published
      .collection_not_expired
      .label_begins_with(query)
      .by_label_language(I18n.locale)
      .includes(:target)
      .order(Arel.sql("LOWER(#{Label::Base.table_name}.value)"))
      .joins(:owner)
      .where(concepts: { type: Iqvoc::Collection.base_class_name })
      .references(:collections, :labels, :labelings)
  end
end
