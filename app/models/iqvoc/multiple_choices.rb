class Iqvoc::MultipleChoices < IqvocException
  attr_accessor :choices

  def initialize(message, choices=[])
    self.choices = choices
    super(message)
  end
end
