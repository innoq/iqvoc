module FormHelper

  ## Generates verbose bootstrap wrapper HTML for generic forms
  ## Use simple_form_for and it's helpers for forms focused on records
  #
  ## Accepts a hash of arguments with the following keys:
  ## id: id attribute of the input element (necessary for accessible labels)
  ## label: label text
  def input_block(options = {}, &block)
    label_text = options.delete(:label)
    id = options.delete(:id)

    label = if label_text
      label_tag(id, label_text, :class => 'control-label')
    else
      ActiveSupport::SafeBuffer.new # empty safe string
    end

    content_tag(:div, :class => 'control-group') do
      label <<
      content_tag(:div, :class => 'controls') do
        capture(&block)
      end
    end
  end

end