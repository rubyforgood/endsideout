module Contentable
  extend ActiveSupport::Concern

  included do
    has_one :content, as: :contentable
  end
end