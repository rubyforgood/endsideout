class ContentModule < ApplicationRecord
  include Ordered

  belongs_to :program
  has_many :contents, -> { ordered }, dependent: :destroy
  has_many :games, through: :contents, source: :contentable, source_type: "Game"
  has_many :links, through: :contents, source: :contentable, source_type: "Link"
  has_many :classroom_modules, dependent: :restrict_with_error

  enum :level, { basic: "basic", moderate: "moderate", advanced: "advanced" }, validate: true

  validates :name, :level, presence: true

  # A module that joins another program or level goes to the end of it.
  before_update :append_to_siblings, if: -> { program_id_changed? || level_changed? }

  def available_games
    Game.where.not(id: games).order(:title)
  end

  private

  # Modules are ordered within one program and level, the same grouping the admin index shows.
  def position_siblings
    program.content_modules.where(level: level)
  end
end
