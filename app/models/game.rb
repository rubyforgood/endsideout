class Game < ApplicationRecord
  has_many :contents, as: :contentable, dependent: :destroy
  has_many :content_modules, through: :contents
  # TODO: Ask the client whether deleting a game should be blocked when students have attempts
  # (dependent: :restrict_with_error) instead of deleting their attempt history.
  has_many :game_attempts, dependent: :destroy

  validates :title, :slug, presence: true
  validates :title, :slug, uniqueness: true

  scope :not_in, ->(content_module) { where.not(id: content_module.contents.games.select(:contentable_id)) }

  scope :with_attempt_counts, -> {
    left_joins(:game_attempts).select("games.*, COUNT(game_attempts.id) AS attempts_count").group(:id)
  }

  # Uses the preselected count from with_attempt_counts when present, avoiding N+1 on lists.
  def attempts_count
    has_attribute?(:attempts_count) ? self[:attempts_count] : game_attempts.count
  end

  def destroy_with_attachable?
    false
  end
end
