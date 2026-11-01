module Contentable
  extend ActiveSupport::Concern

  # Whether the content record owns this contentable, so the contentable is destroyed together with it.
  #
  # @return [Boolean]
  def owned_by_content?
    false
  end
end
