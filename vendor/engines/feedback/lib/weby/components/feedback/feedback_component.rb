class FeedbackComponent < Component
  component_settings :label, :groups_id 

  i18n_settings :label

  validate :label_present

  def label_present
    errors.add(:label, :blank) if label.blank?
  end
  private :label_present

  alias :_groups_id :groups_id
  def groups_id
    _groups_id.blank? ? "" : _groups_id
  end

  def parse_groups(site)
    if groups_id.include? ""
      nil
    else
      groups_site = site.groups 
      "".tap do |group_names|
        groups_site.each do |group|
          group_names << group.name + "," if groups_id.include? group.id.to_s
        end
      end
    end
  end

  def checked?(id)
    groups_id.include? id.to_s
  end

  def default_alias
    self.label
  end
end