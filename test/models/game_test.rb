require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "should not save game without title" do
    game = Game.new(slug: "test-slug")
    assert_not game.save, "Saved the game without a title"
  end

  test "should not save game without slug" do
    game = Game.new(title: "Test Game")
    assert_not game.save, "Saved the game without a slug"
  end

  test "should not save game with duplicate title" do
    Game.create!(title: "Test Game", slug: "test-slug")
    duplicate_game = Game.new(title: "Test Game", slug: "another-slug")
    assert_not duplicate_game.save, "Saved the game with a duplicate title"
  end

  test "destroying a game destroys all its contents" do
    game = Game.create!(title: "Shared Game", slug: "shared-game")
    2.times do |i|
      ContentModule.create!(program: programs(:one), level: "basic", name: "Module #{i}").contents.create!(contentable: game)
    end

    assert_difference "Content.count", -2 do
      game.destroy!
    end
    assert_empty Content.where(contentable: game)
  end

  test "available_for returns games not in the module, ordered by title" do
    content_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Module")
    other_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Other Module")
    in_module = Game.create!(title: "In Module", slug: "in-module").tap do
      content_module.contents.create!(contentable: it)
    end
    in_other_module = Game.create!(title: "B In Other Module", slug: "in-other-module").tap do
      other_module.contents.create!(contentable: it)
    end
    in_no_module = Game.create!(title: "A In No Module", slug: "in-no-module")


    available = Game.available_for(content_module)

    assert_not_includes available, in_module
    assert_equal [ in_no_module, in_other_module ], available.where(id: [ in_module, in_other_module, in_no_module ]).to_a
  end

  test "destroying a game deletes its student attempts" do
    assert_difference "GameAttempt.count", -games(:one).game_attempts.count do
      games(:one).destroy!
    end
    assert_empty GameAttempt.where(game: games(:one))
  end

  test "should not save game with duplicate slug" do
    Game.create!(title: "Test Game", slug: "test-slug")
    duplicate_game = Game.new(title: "Another Game", slug: "test-slug")
    assert_not duplicate_game.save, "Saved the game with a duplicate slug"
  end
end
