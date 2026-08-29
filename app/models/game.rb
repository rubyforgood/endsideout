class Game < ApplicationRecord
  include Contentable

  has_many :game_attempts, dependent: :destroy

  validates :title, :slug, presence: true
  validates :title, :slug, uniqueness: true

  def destroy_with_attachable?
    false
  end
end
