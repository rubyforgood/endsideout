require "test_helper"

class GameAttemptsControllerTest < ActionDispatch::IntegrationTest
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
    attempt.start!

    assert_not attempt.finished?

    post finish_game_attempts_url, params: { token: token, game_attempt: { outcome: "win", score: 100 } }
    assert_response :success

    response_json = JSON.parse(response.body)
    assert_equal "ok", response_json["status"]
    assert attempt.reload.finished?
  end

  test "cannot finish an unstarted game attempt" do
    token = GameAttempt.generate_token(
      student_id: game_attempts(:one).student_id,
      game_id: game_attempts(:one).game_id
    )

    post finish_game_attempts_url, params: { token: token, game_attempt: { outcome: "win", score: 100 } }
    assert_response :unprocessable_entity

    # record is created, but not started, so it should not be finished
    assert GameAttempt.find_by(token: token).present?

    response_json = JSON.parse(response.body)
    assert_equal "error", response_json["status"]
    assert_equal "Game attempt has not been started", response_json["message"]
  end
end
