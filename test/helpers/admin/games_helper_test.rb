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
    contents(:one).dup.update!(content_module: content_modules(:two), position: 1)

    assert_equal "Delete this game? It will be removed from 2 modules.", delete_game_confirmation(@game.reload)
  end

  test "warns about attempts only" do
    @game = games(:two)
    attempt = game_attempts(:two)
    4.times { |i| attempt.dup.update!(token: "extra-#{i}") }

    assert_equal "Delete this game? 5 student attempts will be deleted.", delete_game_confirmation(@game.reload)
  end

  test "warns about modules and attempts" do
    contents(:one).dup.update!(content_module: content_modules(:two), position: 1)
    4.times { |i| game_attempts(:one).dup.update!(token: "extra-#{i}") }

    assert_equal "Delete this game? It will be removed from 2 modules and 5 student attempts will be deleted.",
      delete_game_confirmation(@game.reload)
  end

  test "uses the preselected attempt count for games from with_attempt_counts" do
    game = Game.includes(:contents).with_attempt_counts.find(@game.id)

    assert_no_queries { delete_game_confirmation(game) }
    assert_includes delete_game_confirmation(game), "1 student attempt will be deleted"
  end
end
