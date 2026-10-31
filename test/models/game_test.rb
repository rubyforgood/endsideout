require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "should not save game without title" do
    game = Game.new(slug: "test-slug", content_module: ContentModule.new)
    assert_not game.save, "Saved the game without a title"
  end

  test "should not save game without slug" do
    game = Game.new(title: "Test Game", content_module: ContentModule.new)
    assert_not game.save, "Saved the game without a slug"
  end

  test "should not save game with duplicate title" do
    content_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Test Module")
    Game.create!(title: "Test Game", slug: "test-slug", content_module: content_module)
    duplicate_game = Game.new(title: "Test Game", slug: "another-slug", content_module: content_module)
    assert_not duplicate_game.save, "Saved the game with a duplicate title"
  end

  test "destroying a game destroys all its contents" do
    other_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Other Module")
    other_module.contents.create!(contentable: games(:one))

    assert_difference "Content.count", -2 do
      games(:one).destroy!
    end
    assert_empty Content.where(contentable: games(:one))
  end

  test "should not save game with duplicate slug" do
    content_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Test Module")
    Game.create!(title: "Test Game", slug: "test-slug", content_module: content_module)
    duplicate_game = Game.new(title: "Another Game", slug: "test-slug", content_module: content_module)
    assert_not duplicate_game.save, "Saved the game with a duplicate slug"
  end
end
