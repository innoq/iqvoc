class Label::SKOS::Base < Label::Base

  after_initialize :publish

  # ********** Methods

  def publish
    self.published_at = Time.now
  end

end
