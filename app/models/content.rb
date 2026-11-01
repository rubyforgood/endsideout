class Content < ApplicationRecord
  include Ordered

  belongs_to :content_module

  delegated_type :contentable, types: %w[Link Game]

  validates :contentable_id, uniqueness: {
    scope: [ :content_module_id, :contentable_type ],
    message: "is already in this module"
  }

  # Ensure the associated contentable record is destroyed if allowed before destroying this content.
  # This allows us to have dependent: :destroy behavior for contentable records.
  before_destroy :destroy_owned_record

  private

  def position_siblings
    content_module.contents
  end

  def destroy_owned_record
    contentable.destroy if contentable.owned_by_content?
  end
end
