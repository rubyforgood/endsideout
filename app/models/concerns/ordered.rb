# Orders records by an integer +position+ column. New records go to the end of their siblings.
#
# A model that includes this must define +position_siblings+, the relation of records it is
# ordered among (for example, the contents of one module).
module Ordered
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order(:position) }

    before_create :append_to_siblings
  end

  private

  def position_siblings
    raise NotImplementedError, "#{self.class} must define #position_siblings to be ordered"
  end

  def append_to_siblings
    self.position = (position_siblings.maximum(:position) || 0) + 1
  end
end
