class ContentModule < ApplicationRecord
  belongs_to :program
  has_many :links, dependent: :destroy
  has_many :games # we don't want to destroy these because they should be reusable among content modules
  has_many :classroom_modules, dependent: :restrict_with_error

  enum :level, { basic: "basic", moderate: "moderate", advanced: "advanced" }, validate: true

  validates :name, :level, presence: true

  default_scope { order(:position) }
end
