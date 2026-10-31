require "test_helper"

class GameAttemptTest < ActiveSupport::TestCase
  test "can start a game attempt" do
    attempt = GameAttempt.create(student: students(:one), game: games(:one))

    refute attempt.started?

    attempt.start!

    assert attempt.started?
    refute attempt.finished?
  end

  test "can finish a game attempt" do
    attempt = GameAttempt.create(student: students(:one), game: games(:one))
    attempt.start!

    refute attempt.finished?

    attempt.finish!(outcome: "win", score: 100)

    assert attempt.finished?
  end

  test "new game attempts require a token" do
    attempt = GameAttempt.new(student: students(:one), game: games(:one))
    assert_not attempt.valid?
    assert_includes attempt.errors[:token], "can't be blank"
  end

  test "creating an attempt increments the game's attempt count" do
    game = games(:one)

    assert_difference -> { game.reload.game_attempts_count }, 1 do
      GameAttempt.create!(student: students(:one), game: game, token: "counter-token")
    end
  end
end
