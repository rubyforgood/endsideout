class ContentModule < ApplicationRecord
  belongs_to :program
  has_many :links, dependent: :destroy

  enum :level, { basic: "basic", moderate: "moderate", advanced: "advanced" }, validate: true

  validates :name, :level, presence: true

  default_scope { order(:position) }
end
