class ContentModule < ApplicationRecord
  include Ordered

  belongs_to :program
  has_many :contents, dependent: :destroy
  has_many :links, -> { ordered },
    through: :contents,
    source: :contentable,
    source_type: "Link"
  has_many :games,
    through: :contents,
    source: :contentable,
    source_type: "Game"
  has_many :classroom_modules, dependent: :restrict_with_error

  enum :level, { basic: "basic", moderate: "moderate", advanced: "advanced" }, validate: true

  validates :name, :level, presence: true
end
