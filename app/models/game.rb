class Game < ApplicationRecord
  has_many :contents, as: :contentable, dependent: :destroy
  has_many :game_attempts, dependent: :destroy

  validates :title, :slug, presence: true
  validates :title, :slug, uniqueness: true

  scope :not_in, ->(content_module) { where.not(id: content_module.contents.games.select(:contentable_id)) }

  def destroy_with_attachable?
    false
  end
end
