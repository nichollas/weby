class MenuItem < ActiveRecord::Base
  weby_content_i18n :title, :description, required: :title

  scope :published, where(publish: true)

  belongs_to :target, polymorphic: true
  
  belongs_to :menu
  validates :menu_id,
    presence: true

	belongs_to :parent, class_name: 'MenuItem'
	has_many :children, class_name: 'MenuItem', foreign_key: 'parent_id', dependent: :destroy

  validates_format_of :html_class, :with => /^[A-Za-z0-9_\-]*$/
  validates :position, numericality: true, allow_nil: false

  after_save do
    if publish_changed?
      children.each do |child|
        child.update_attribute(:publish, publish)
      end
    end
    if menu_id_changed?
      children.each do |child|
        child.update_attribute(:menu_id, menu_id)
      end
    end
  end

  def update_positions positions
    positions = positions_by_parent(positions)
    positions.fetch(parent_id, []).each_with_index do |item_id, idx|
      MenuItem.find(item_id).update_attribute(:position, idx+1)
    end
    if parent_id != @new_parent
      positions.fetch(@new_parent, []).each_with_index do |item_id, idx|
        attrs = {position: idx+1}
        attrs[:parent_id] = @new_parent if item_id == id
        MenuItem.find(item_id).update_attributes(attrs)
      end
    end
  end

  def self.import attrs, options={}
    return attrs.each{|attr| self.import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs.except!('id', 'created_at', 'updated_at', 'menu_id', 'parent_id', 'target_id', 'target_type')
    attrs.except!('url') unless attrs['url'].match(/^https?:\/\//)
    children = attrs.delete('children')

    attrs['i18ns'] = attrs['i18ns'].map{|i18n| self::I18ns.new(i18n.except('id', 'created_at', 'updated_at', 'menu_item_id')) }

    menu_item = self.create!(attrs.merge(parent_id: options[:parent_id]))
    if menu_item.persisted?
      children.each do |child|
        self.import child, parent_id: menu_item.id
      end
    end
  end

  def serializable_hash options={}
    options.merge!({include: [:i18ns, :children]})
    super options
  end

  private

  def positions_by_parent serialized
    hierarchy = {}
    serialized.each do |item, parent|
      parent = ['root','null'].include?(parent) ? nil : parent.to_i
      hierarchy[parent] ||= []
      hierarchy[parent] << item.to_i
      @new_parent = parent if item.to_i == id
    end
    hierarchy
  end
end
