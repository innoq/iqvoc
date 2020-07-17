class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render template: 'errors/not_found', status: 404 }
      format.any  { head 404 }
    end
  end
end
