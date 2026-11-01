class Link < ApplicationRecord
  include Contentable

  # :delete skips Content callbacks to avoid a destroy loop
  has_one :content, as: :contentable, dependent: :delete
  has_one :content_module, through: :content

  enum :link_type, { survey: "survey" }, validate: true

  validates :title, :url, :link_type, presence: true
  validates :url, format: { with: /\Ahttps?:\/\/.+\z/i, message: "must start with http:// or https://" }, allow_blank: true

  def owned_by_content?
    true
  end
end
