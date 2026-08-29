class ContentModule < ApplicationRecord
  include Ordered

  belongs_to :program
  has_many :links, -> { ordered },
    through: :contents,
    source: :contentable,
    source_type: 'Link'

  has_many :games, dependent: :nullify
  has_many :classroom_modules, dependent: :restrict_with_error
  has_many :contents, dependent: :destroy

  enum :level, { basic: "basic", moderate: "moderate", advanced: "advanced" }, validate: true

  validates :name, :level, presence: true
end
