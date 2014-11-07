module RdfNamespacesHelper
  include *Iqvoc.default_rdf_namespace_helper_modules

  def iqvoc_default_rdf_namespaces
    Iqvoc.rdf_namespaces.merge({
      default: root_url(format: nil, lang: nil, trailing_slash: true),
      schema: schema_url(format: nil, anchor: '', lang: nil)
    })
  end
end
