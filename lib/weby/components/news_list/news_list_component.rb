class NewsListComponent < Component
  component_settings :quant, :front, :events, :category, :show_image, :image_size,
    :show_date, :date_format, :title, :new_tab

  i18n_settings :title

  validates :quant, presence: true

  def pages(site, page)
    category.blank? ?
      site.pages.order('created_at desc').available
    .send(front ? 'front' : 'no_front').send(events ? 'scoped' : 'news')
    .page(page).per(quant) :
      site.pages.order('created_at desc').available.tagged_with(category, any: true)
    .send(front ? 'front' : 'no_front').send(events ? 'scoped' : 'news')
    .page(page).per(quant)
  end

  alias :_quant :quant
  def quant
    _quant.blank? ? 5 : _quant.to_i
  end

  alias :_front :front
  def front
    _front.blank? ? false : _front.to_i == 1
  end

  alias :_events :events
  def events
    _events.blank? ? false : _events.to_i == 1
  end

  alias :_show_image :show_image
  def show_image
    _show_image.blank? ? false : _show_image.to_i == 1
  end

  alias :_image_size :image_size
  def image_size
    _image_size.blank? ? '48' : _image_size
  end

  alias :_show_date :show_date
  def show_date
    _show_date.blank? ? false : _show_date.to_i == 1
  end

  alias :_date_format :date_format
  def date_format
    _date_format.blank? ? :short : _date_format.to_sym
  end

  alias :_category :category
  def category
    _category.blank? ? nil : _category
  end

  alias :_new_tab :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  def default_alias
    self.category
  end

  def image_sizes
    ['32', '48', '64', '128']
  end

  def date_formats
    ['default','mini','short','medium','long','event_date_short','event_date_full']
  end

  def title_for_link
    if self.title.present?
      self.title
    elsif self.category.present?
      self.category.camelize
    end
  end
end
