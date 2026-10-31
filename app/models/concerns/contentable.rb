# A content owns its link, which is deleted together with it.
# A game is shared across modules, so it is kept when a content is removed.
module Contentable
  extend ActiveSupport::Concern

  def owned_by_content?
    false
  end
end
