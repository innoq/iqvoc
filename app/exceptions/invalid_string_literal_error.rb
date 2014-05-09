class InvalidStringLiteralError < ArgumentError
  attr_reader :original
  def initialize(msg, original = $!)
    super(msg)
    @original = original;
  end
end
