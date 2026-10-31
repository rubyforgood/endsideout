# Orders records by an integer +position+ column. New records go to the end of their siblings.
module Ordered
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order(:position) }

    before_create :append_to_siblings
  end

  private

  # This method is required to override. It is the relation of records this record is
  # ordered among (for example, the contents of one module).
  #
  # @return [ActiveRecord::Relation]
  def position_siblings
    raise NotImplementedError, "#{self.class} must define #position_siblings to be ordered"
  end

  def append_to_siblings
    self.position = (position_siblings.maximum(:position) || 0) + 1
  end
end
