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

  test "rejects a tampered token with a JSON error" do
    post start_game_attempts_url, params: { token: "not-a-real-token" }, as: :json
    assert_response :unprocessable_entity

    response_json = JSON.parse(response.body)
    assert_equal "error", response_json["status"]
    assert_equal "Invalid token", response_json["message"]
    assert_equal 0, GameAttempt.where(token: "not-a-real-token").count
  end

  test "accepts a JSON body" do
    token = valid_token

    post start_game_attempts_url, params: { token: token }, as: :json
    assert_response :success
    assert GameAttempt.find_by(token: token).started?
  end

  test "allows CORS requests from the games host" do
    origin = "https://#{Rails.configuration.x.external_games.host}"

    post start_game_attempts_url, params: { token: valid_token }, as: :json, headers: { "Origin" => origin }

    assert_response :success
    assert_equal origin, response.headers["Access-Control-Allow-Origin"]
    assert_includes response.headers["Vary"], "Origin"
  end

  test "does not allow CORS requests from other origins" do
    post start_game_attempts_url, params: { token: valid_token }, as: :json,
      headers: { "Origin" => "https://example.com" }

    assert_nil response.headers["Access-Control-Allow-Origin"]
  end

  test "answers CORS preflight requests for start and finish" do
    origin = "https://#{Rails.configuration.x.external_games.host}"

    %i[start finish].each do |action|
      process :options, "/game_attempts/#{action}", headers: {
        "Origin" => origin,
        "Access-Control-Request-Method" => "POST",
        "Access-Control-Request-Headers" => "Content-Type"
      }

      assert_response :success
      assert_equal origin, response.headers["Access-Control-Allow-Origin"]
      assert_includes response.headers["Access-Control-Allow-Methods"].downcase, "post"
      assert_includes response.headers["Access-Control-Allow-Headers"].downcase, "content-type"
    end
  end

  private

  def valid_token
    GameAttempt.generate_token(
      student_id: game_attempts(:one).student_id,
      game_id: game_attempts(:one).game_id
    )
  end
end
