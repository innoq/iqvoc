class ReverseMatchesController < ApplicationController
  include ReverseMatchErrors
  before_action :prepare_match, only: [:add_match, :remove_match]
  skip_before_action :verify_authenticity_token

  def add_match
    # NOTE: currently it's only allowed to add matches to published concepts
    # which are _NOT_ in processing. See older commits how to work with
    # currently edited concepts
    matches = @target_match_class.constantize.find_by(concept_id: @published_concept.id, value: @uri)
    render_response :mapping_exists and return if matches
    unpublished_concept = @published_concept.branch(@botuser)
    unpublished_concept.save
    @target_match_class.constantize.create(concept_id: unpublished_concept.id, value: @uri)
    unpublished_concept.publish!

    render_response :mapping_added
  end

  def remove_match
    begin
      unpublished_concept = @published_concept.branch(@botuser)
      unpublished_concept.save
      match = @target_match_class.constantize.find_by(concept_id: unpublished_concept.id, value: @uri)
      render_response :unknown_relation and return if match.nil?
      match.destroy
      unpublished_concept.publish!
    rescue
      render_response :server_error and return
    end

    render_response :mapping_removed
  end

  protected

  def prepare_match
    begin
      origin = params.require(:origin)
      @uri = params.require(:uri)
      match_class = params.require(:match_class)
    rescue
      render_response :parameter_missing and return
    end

    match_classes = Iqvoc::Concept.reverse_match_class_names
    render_response :unknown_match and return if match_classes.values.exclude? match_class
    klass = match_classes.key(match_class)
    @target_match_class = klass.constantize.reverse_match_class_name
    render_response :unknown_match and return if @target_match_class.nil?

    iqvoc_sources = Iqvoc.config['sources.iqvoc'].map{ |s| URI.parse(s) }
    render_response :no_referer and return if request.referer.nil?
    referer = URI.parse(request.referer)

    unless iqvoc_sources.detect {|s| referer.starts_with?(s) }
      Rails.logger.info "Could not create reverse match - unknown referer: #{referer}"
      render_response :unknown_referer and return
    end

    @botuser = BotUser.instance
    @published_concept = Iqvoc::Concept.base_class.by_origin(origin).published.last
    @botuser.can? :branch, @published_concept

    unpublished_concepts = Iqvoc::Concept.base_class.by_origin(origin).unpublished
    render_response :in_processing and return if unpublished_concepts.any?
  end

  def render_response(type)
    message = messages[type]
    respond_to do |format|
      format.json { render message }
    end
  end
end
