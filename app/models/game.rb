class Game < ApplicationRecord
  belongs_to :content_module

  validates :title, :slug, presence: true
  validates :title, :slug, uniqueness: true
end
