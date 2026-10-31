# Orders records by an integer +position+ column and lets them swap places with a neighbor.
#
# A model that wants to move records must define +position_siblings+, the relation of
# records it moves among (for example, the contents of one module).
module Ordered
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order(:position) }
  end

  def move_up
    swap_position_with position_siblings.where(position: ...position).order(position: :desc).first
  end

  def move_down
    swap_position_with position_siblings.where("position > ?", position).order(:position).first
  end

  private

  def position_siblings
    raise NotImplementedError, "#{self.class} must define #position_siblings to be moved"
  end

  def swap_position_with(neighbor)
    return unless neighbor

    transaction do
      own_position = position
      update!(position: neighbor.position)
      neighbor.update!(position: own_position)
    end
  end

  # Models opt in with +before_create :append_to_siblings+.
  def append_to_siblings
    self.position ||= (position_siblings.maximum(:position) || 0) + 1
  end
end
