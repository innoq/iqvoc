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

  def sidebar_item(opts = {}, &block)
    css_class = ''
    css_class << 'active' if opts.delete(:active)

    content = if block_given?
      capture(&block)
    else
      desc = ActiveSupport::SafeBuffer.new
      if icon = opts.delete(:icon)
        desc << icon(icon) << " "
      end
      desc << opts.delete(:text).to_s
      link_to(desc.html_safe, opts.delete(:path))
    end

    content_tag :li, content, :class => css_class
  end

end
