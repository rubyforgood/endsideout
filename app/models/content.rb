class Content < ApplicationRecord
  include Ordered

  belongs_to :content_module

  delegated_type :contentable, types: %w[Link Game]

  validates :contentable_id, uniqueness: { scope: [ :content_module_id, :contentable_type ] }

  before_create :append_to_content_module

  # Ensure the associated contentable record is destroyed if allowed before destroying this content.
  # This allows us to have dependent: :destroy behavior for contentable records.
  before_destroy :destroy_owned_record

  def move_up
    swap_position_with siblings.where(position: ...position).order(position: :desc).first
  end

  def move_down
    swap_position_with siblings.where("position > ?", position).order(:position).first
  end

  private

  def siblings
    content_module.contents.unscope(:order)
  end

  def swap_position_with(neighbor)
    return unless neighbor

    transaction do
      own_position = position
      update!(position: neighbor.position)
      neighbor.update!(position: own_position)
    end
  end

  def append_to_content_module
    self.position = (siblings.maximum(:position) || 0) + 1
  end

  def destroy_owned_record
    contentable.destroy if contentable.destroy_with_attachable?
  end
end
