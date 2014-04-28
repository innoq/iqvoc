module RdfNamespacesHelper
  include *Iqvoc.default_rdf_namespace_helper_modules

  def iqvoc_default_rdf_namespaces
    Iqvoc.rdf_namespaces.merge({
      :default => root_url(:format => nil, :lang => nil, :trailing_slash => true).gsub(/\/\/$/, "/"), # gsub because of a Rails bug :-(
      :coll => rdf_collections_url(:trailing_slash => true, :lang => nil, :format => nil),
      :schema => schema_url(:format => nil, :anchor => "", :lang => nil)
    })
  end
end
