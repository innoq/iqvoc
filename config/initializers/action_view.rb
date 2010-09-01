ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if instance.error_message.kind_of?(Array)
    %(#{html_tag}<span class="fieldWithErrors">&nbsp;</span>)
  else
    %(#{html_tag}<span class="fieldWithErrors">&nbsp;</span>)
  end
end
