class Content < ApplicationRecord
  belongs_to :content_module, optional: true

  delegated_type :contentable, types: %w[Link Game]
end
