require 'concerns/dataset_initialization'

class RemoteLabelsController < ApplicationController
  include DatasetInitialization

  def show
    @datasets = init_datasets

    concept_url = params[:concept_url]
    ensure_known_dataset(concept_url)

    label = @dataset.find_label(concept_url)
    unless label
      head 404
      return
    end

    respond_to do |format|
      format.json do
        render :json => { :label => label }
      end
    end
  end

  private
  def ensure_known_dataset(concept_url)
    @dataset = @datasets.detect {|d| concept_url.to_s.start_with?(d.url.to_s) }
    unless @dataset
      head 422
      return
    end
  end

end
