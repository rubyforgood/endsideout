require "test_helper"

class GameAttemptsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get game_attempt_url(game_attempts(:one))
    assert_response :success
  end

  test "should create a game attempt" do
    post game_attempts_url, params: { student_id: students(:ada).id, game_id: games(:one).id }
    assert_response :success
  end

  test "should update a game attempt" do
    patch game_attempt_url(game_attempts(:one)), params: { outcome: "win", score: 100 }
    assert_response :success
  end
end
