# encoding: utf-8

class RdfUploader < Base
  def extension_allowlist
    %w(nt)
  end

  def content_type_allowlist
    ['application/n-triples']
  end
end
