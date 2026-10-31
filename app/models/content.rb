class Content < ApplicationRecord
  include Ordered

  belongs_to :content_module

  delegated_type :contentable, types: %w[Link Game]

  validates :contentable_id, uniqueness: { scope: [ :content_module_id, :contentable_type ] }

  before_create :append_to_siblings

  # Ensure the associated contentable record is destroyed if allowed before destroying this content.
  # This allows us to have dependent: :destroy behavior for contentable records.
  before_destroy :destroy_owned_record

  private

  def position_siblings
    content_module.contents.unscope(:order)
  end

  def destroy_owned_record
    contentable.destroy if contentable.destroy_with_attachable?
  end
end
