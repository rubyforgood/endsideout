class Link < ApplicationRecord
  # :delete skips Content callbacks, so Content#destroy_owned_record cannot loop back into Link#destroy
  has_one :content, as: :contentable, dependent: :delete
  has_one :content_module, through: :content

  enum :link_type, { survey: "survey" }, validate: true

  validates :title, :url, :link_type, presence: true
  validates :url, format: { with: /\Ahttps?:\/\/.+\z/i, message: "must start with http:// or https://" }, allow_blank: true

  def destroy_with_attachable?
    true
  end
end
