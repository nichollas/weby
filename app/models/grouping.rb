class Grouping < ActiveRecord::Base
  attr_accessible :name, :site_ids

  has_and_belongs_to_many :sites, order: 'name asc'

  validates :name, presence: true
end
