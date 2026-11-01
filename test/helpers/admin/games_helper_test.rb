require "test_helper"

class Admin::GamesHelperTest < ActionView::TestCase
  test "plain confirmation when the game has no modules or attempts" do
    game = create_game

    assert_equal "Delete this game?", delete_game_confirmation(game)
  end

  test "warns about one module and one attempt in the singular" do
    game = create_game
    add_to_new_module(game)
    create_attempt(game)

    assert_equal "Delete this game? It will be removed from 1 module and 1 student attempt will be deleted.",
      delete_game_confirmation(game)
  end

  test "warns about modules only" do
    game = create_game
    2.times { add_to_new_module(game) }

    assert_equal "Delete this game? It will be removed from 2 modules.", delete_game_confirmation(game)
  end

  test "warns about attempts only" do
    game = create_game
    2.times { create_attempt(game) }

    assert_equal "Delete this game? 2 student attempts will be deleted.", delete_game_confirmation(game)
  end

  test "warns about modules and attempts" do
    game = create_game
    2.times { add_to_new_module(game) }
    2.times { create_attempt(game) }

    assert_equal "Delete this game? It will be removed from 2 modules and 2 student attempts will be deleted.",
      delete_game_confirmation(game)
  end

  private
    def create_game
      Game.create!(title: "Test Game", slug: "test-game")
    end

    def add_to_new_module(game)
      content_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Module #{ContentModule.count}")
      content_module.contents.create!(contentable: game)
    end

    def create_attempt(game)
      GameAttempt.create!(game: game, student: students(:one), token: SecureRandom.hex)
    end
end
