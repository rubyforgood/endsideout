class Link < ApplicationRecord
  belongs_to :content_module

  enum :link_type, { survey: "survey", game: "game" }, validate: true

  validates :title, :url, :link_type, presence: true

  default_scope { order(:position) }
end
