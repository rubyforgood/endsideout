class Game < ApplicationRecord
  include Contentable

  has_many :contents, as: :contentable, dependent: :destroy
  has_many :content_modules, through: :contents
  has_many :game_attempts, dependent: :destroy

  validates :title, :slug, presence: true
  validates :title, :slug, uniqueness: true
end
