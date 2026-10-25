# The games run on another origin (see external_games.rb) and call the game
# attempts API from the browser.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://#{Rails.configuration.x.external_games.host}"

    resource "/game_attempts/*",
      headers: %w[Content-Type],
      methods: %i[post options]
  end
end
