module NavigationHelper

  # expects an array of hashes with the following members:
  # :content - usually a navigation link
  # :active? - an optional function determining whether the respective item is
  #     currently active
  # :controller - an optional string, used instead of `active?` to check for a
  #     specific controller
  # :authorized? - an optional function determining whether the respective item
  #     is available to the current user (defaults to true)
  def nav_items(items)
    items.map do |item|
      if (not item[:authorized?]) || instance_eval(&item[:authorized?])
        active = item[:active?] ? instance_eval(&item[:active?]) : (item[:controller] ? params[:controller] == item[:controller] : false)

        content_tag "li", instance_eval(&item[:content]),
            :class => ("active" if active)
      end
    end.join.html_safe
  end

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
    if perms = opts.delete(:perms)
      return nil if cannot?(*perms)
    end

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
      link_to(desc.html_safe, opts.delete(:path), opts)
    end

    content_tag :li, content, :class => css_class
  end

  def quick_search_class
    klass = if Labeling.const_defined?(:SKOSXL)
      Labeling::SKOSXL::Base
    else
      Labeling::SKOS::Base
    end

    klass.name.parameterize
  end

end
