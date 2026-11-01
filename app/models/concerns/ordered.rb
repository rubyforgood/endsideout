# Orders records by an integer +position+ column. New records go to the end of their siblings.
# and existing ones can swap places with a neighbor.
module Ordered
  extend ActiveSupport::Concern

  DIRECTIONS = %i[up down].freeze

  included do
    scope :ordered, -> { order(:position) }

    before_create :append_to_siblings
  end

  # @param [:up, :down] direction
  def move(direction)
    case direction
    when :up then move_up
    when :down then move_down
    else raise ArgumentError, "Unknown direction: #{direction.inspect}"
    end
  end

  def move_up
    swap_position_with position_siblings.where(position: ...position).reorder(position: :desc).first
  end

  def move_down
    swap_position_with position_siblings.where(position: (position + 1)..).reorder(:position).first
  end

  private

  # This method is required to override. It is the relation of records this record is
  # ordered among (for example, the contents of one module).
  #
  # @return [ActiveRecord::Relation]
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

  def append_to_siblings
    self.position = (position_siblings.maximum(:position) || 0) + 1
  end
end
