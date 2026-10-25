require "test_helper"

class ExternalGameRouteTest < ActionDispatch::IntegrationTest
  test "the direct route works correctly" do
    expected_host = "https://staging--endsideout-games.netlify.app"
    assert_equal "#{expected_host}/games/game-1", external_game_url("game-1")
    # ensure URL encoding is applied to the token query parameter
    assert_equal "#{expected_host}/games/game-1?token=abc%3D%3D", external_game_url("game-1", token: "abc==")
  end
end
