require "test_helper"

class ExternalGameRouteTest < ActionDispatch::IntegrationTest
  test "points at the staging games host outside production" do
    assert_equal "staging--endsideout-games.netlify.app", Rails.configuration.x.external_games.host
    assert_equal "https://staging--endsideout-games.netlify.app/games/game-1", external_game_url("game-1")
  end

  test "adds the token as a query parameter" do
    assert_equal "https://staging--endsideout-games.netlify.app/games/game-1?token=abc%3D%3D",
      external_game_url("game-1", token: "abc==")
  end

  private

  def external_game_url(...) = Rails.application.routes.url_helpers.external_game_url(...)
end
