class VirtuosoSyncsController < ApplicationController
  
  before_filter :check_authorization
  
  def new
  end
  
  def create
    time = Time.now
    
    rdf_helper = Object.new.extend(RdfHelper)
    
    Iqvoc::Concept.base_class.published.unsynced.all.each do |concept|
      concept.update_attribute(:rdf_updated_at, time) if RdfStore.mass_import(concept.rdf_uri, rdf_helper.render_ttl_for_concept(concept))
    end
        
    Iqvoc::Label.base_class.published.unsynced.all.each do |label|
      label.update_attribute(:rdf_updated_at, time) if RdfStore.mass_import(label.rdf_uri, rdf_helper.render_ttl_for_label(label))
    end
    
    flash[:notice] = I18n.t("txt.controllers.virtuoso_syncs.success")
    
    render :action => "new"
  end
  
  private
  def check_authorization
    authorize! :use, :dashboard
  end
  
end