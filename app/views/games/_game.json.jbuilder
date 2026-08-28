json.extract! game, :id, :title, :slug, :content_module_id, :description, :created_at, :updated_at
json.url game_url(game, format: :json)
