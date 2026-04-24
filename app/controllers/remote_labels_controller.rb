class RemoteLabelsController < ApplicationController
  include DatasetInitialization

  rescue_from ServiceUnavailableError, with: :handle_service_unavailable
  
  def show
    @datasets = init_datasets

    concept_url = params[:concept_url]

    # ensure known dataset
    @dataset = @datasets.detect { |d| concept_url.to_s.start_with?(d.url.to_s) }
    unless @dataset
      head :unprocessable_entity
      return
    end

    label = @dataset.find_label(concept_url)
    unless label
      head :not_found
      return
    end

    respond_to do |format|
      format.json do
        render json: { label: label }
      end
    end
  end

  private

  def handle_service_unavailable(exception)
    Rails.logger.error("External dataset unavailable: #{exception.url} - #{exception.message}")
    render json: {
      error: 'External service unavailable',
      dataset_url: exception.url.to_s
    }, status: :service_unavailable
  end
end
