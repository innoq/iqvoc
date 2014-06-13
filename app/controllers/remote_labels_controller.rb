require 'concerns/dataset_initialization'

class RemoteLabelsController < ApplicationController
  include DatasetInitialization

  def show
    @datasets = init_datasets

    concept_url = params[:concept_url]

    # ensure known dataset
    @dataset = @datasets.detect { |d| concept_url.to_s.start_with?(d.url.to_s) }
    unless @dataset
      head 422
      return
    end

    label = @dataset.find_label(concept_url)
    unless label
      head 404
      return
    end

    respond_to do |format|
      format.json do
        render json: { label: label }
      end
    end
  end
end
