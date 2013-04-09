class Concepts::SchemeController < ApplicationController

  def show
    @scheme = Iqvoc::Concept.root_class.instance
    authorize! :read, @scheme

    @top_concepts = Iqvoc::Concept.base_class.tops.published

    respond_to do |format|
      format.html do
      end
      format.any :rdf, :ttl do
      end
    end
  end

  def edit
    @scheme = Iqvoc::Concept.root_class.instance
    authorize! :update, @scheme
  end

end
