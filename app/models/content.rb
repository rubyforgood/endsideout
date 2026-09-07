class Content < ApplicationRecord
  belongs_to :content_module

  delegated_type :contentable, types: %w[Link Game]

  # Ensure the associated contentable record is destroyed if allowed before destroying this content.
  # This allows us to have dependent: :destroy behavior for contentable records.
  before_destroy :destroy_owned_record

  private

  def destroy_owned_record
    contentable.destroy if contentable.destroy_with_attachable?
  end
end
