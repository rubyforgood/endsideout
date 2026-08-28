module GamesHelper
  ENSIDEOUT_GAMES_URL = "https://endsideoutgames.netlify.app"
  def external_game_url(slug)
    "#{ENSIDEOUT_GAMES_URL}/games/#{slug}"
  end
end
