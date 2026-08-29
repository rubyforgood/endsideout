require "test_helper"

class GameAttemptsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get game_attempt_url(game_attempts(:one))
    assert_response :success

    response_json = JSON.parse(response.body)
    assert_equal game_attempts(:one).id, response_json["id"]
  end

  test "should start a game attempt" do
    token = GameAttempt.generate_token(
      student_id: game_attempts(:one).student_id,
      game_id: game_attempts(:one).game_id
    )

    post start_game_attempts_url, params: { token: token }
    assert_response :success

    response_json = JSON.parse(response.body)
    assert_equal "ok", response_json["status"]

    # assert that a game attempt with the token exists and has been marked as started
    assert GameAttempt.find_by(token: token).started?
  end

  test "should finish a game attempt" do
    token = GameAttempt.generate_token(
      student_id: game_attempts(:one).student_id,
      game_id: game_attempts(:one).game_id
    )

    attempt = GameAttempt.create(
      student_id: game_attempts(:one).student_id,
      game_id: game_attempts(:one).game_id,
      token: token
    )

    assert_not attempt.finished?

    post finish_game_attempts_url, params: { token: token, game_attempt: { outcome: "win", score: 100 } }
    assert_response :success

    response_json = JSON.parse(response.body)
    assert_equal "ok", response_json["status"]
    assert attempt.reload.finished?
  end
end
