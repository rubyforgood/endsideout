require "test_helper"

class Admin::GamesHelperTest < ActionView::TestCase
  setup do
    @game = games(:one)
  end

  test "plain confirmation when the game has no modules or attempts" do
    @game.contents.destroy_all
    @game.game_attempts.destroy_all

    assert_equal "Delete this game?", delete_game_confirmation(@game.reload)
  end

  test "warns about modules only" do
    @game.game_attempts.destroy_all
    content_modules(:two).contents.create!(contentable: @game)

    assert_equal "Delete this game? It will be removed from 2 modules.", delete_game_confirmation(@game.reload)
  end

  test "warns about attempts only" do
    game = games(:two)
    create_attempt(game)

    assert_equal "Delete this game? 2 student attempts will be deleted.", delete_game_confirmation(game.reload)
  end

  test "warns about modules and attempts" do
    content_modules(:two).contents.create!(contentable: @game)
    create_attempt(@game)

    assert_equal "Delete this game? It will be removed from 2 modules and 2 student attempts will be deleted.",
      delete_game_confirmation(@game.reload)
  end

  private
    def create_attempt(game)
      GameAttempt.create!(game: game, student: students(:one), token: SecureRandom.hex)
    end
end
