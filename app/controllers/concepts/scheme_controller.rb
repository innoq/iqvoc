# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

class Concepts::SchemeController < ApplicationController
  resource_description do
    name 'Concept scheme'
  end

  api :GET, 'scheme', "The concept scheme lists the vocabulary's top concepts."
  formats [:html, :ttl, :rdf]
  example <<-DOC
    GET /scheme.ttl
    200

    # omitted namespace definitions
    :achievement_hobbies a skos:Concept;
                         skos:topConceptOf :scheme;
                         skos:inScheme :scheme;
                         skos:prefLabel "Achievement hobbies"@en;
                         skos:narrower :gardening.
    :scheme a skos:ConceptScheme;
            skos:hasTopConcept :achievement_hobbies.
  DOC

  def show
    @scheme = Iqvoc::Concept.root_class.instance
    authorize! :read, @scheme

    @top_concepts = Iqvoc::Concept.base_class.tops.published

    respond_to do |format|
      format.html
      format.any(:rdf, :ttl, :nt)
    end
  end

  def edit
    @scheme = Iqvoc::Concept.root_class.instance
    authorize! :update, @scheme
  end

  def update
    @scheme = Iqvoc::Concept.root_class.instance
    authorize! :update, @scheme

    if @scheme.update_attributes(concept_params)
      flash[:success] = t('txt.controllers.concept_scheme.save.success')
      redirect_to scheme_path
    else
      flash[:error] = t('txt.controllers.concept_scheme.save.error')
      render :edit
    end
  end

  private
  def concept_params
    params.require(:concept).permit!
  end

end
