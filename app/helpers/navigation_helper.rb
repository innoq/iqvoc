module NavigationHelper

  def sidebar(&block)
    content_for :sidebar do
      content_tag :div, :class => 'well sidebar' do
        content_tag :ul, :class => 'nav nav-list' do
          capture(&block)
        end
      end
    end
  end

  def sidebar_header(text)
    content_tag :li, text, :class => 'nav-header'
  end

  def sidebar_item(text = nil, path = nil, active = nil, &block)
    css_class = ''
    css_class << 'active' if active

    content = if block_given?
      capture(&block)
    else
      link_to(text, path)
    end

    content_tag :li, content, :class => css_class
  end

end
