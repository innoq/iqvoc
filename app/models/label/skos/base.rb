class Label::SKOS::Base < Label::Base

  after_initialize :publish

  def publish
    self.published_at = Time.now
  end

end
