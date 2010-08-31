class Iqvoc::AuthorisationRequired < IqvocException
  def initialize
    @message = 'Ypu are not allowed to see this page without successful authorisation.'
  end
end
