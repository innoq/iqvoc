class CollectionsController < ApplicationController

  def index
    @collections = Collection::SKOS::Base.all
  end
  
  def new
    @collection = Collection::SKOS::Base.new
    @collection.language_notes.build if @collection.language_notes.empty?
  end
  
end
