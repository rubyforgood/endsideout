require "test_helper"

class GameAttemptsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get game_attempt_url(game_attempts(:one).token)
    assert_response :success

    response_json = JSON.parse(response.body)
    assert_equal game_attempts(:one).id, response_json["id"]
  end

  test "should start a game attempt" do
    assert_not game_attempts(:one).reload.started?

    post start_game_attempt_url(game_attempts(:one).token)
    assert_response :success

    response_json = JSON.parse(response.body)
    assert_equal "ok", response_json["status"]
    assert game_attempts(:one).reload.started?
  end

  test "should finish a game attempt" do
    assert_not game_attempts(:one).reload.finished?

    post finish_game_attempt_url(game_attempts(:one).token), params: { game_attempt: { outcome: "win", score: 100 } }
    assert_response :success

    response_json = JSON.parse(response.body)
    assert_equal "ok", response_json["status"]
    assert game_attempts(:one).reload.finished?
  end
end
