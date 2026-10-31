require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "delegates to its contentable" do
    content = contents(:one)

    assert_equal games(:one), content.contentable
    assert_equal "Game", content.contentable_type
  end

  test "belongs to a content module" do
    content = contents(:one)

    assert_equal content_modules(:one), content.content_module
  end

  test "appends new content after the highest position in its module" do
    content = content_modules(:one).contents.create!(contentable: games(:two))

    assert_equal 3, content.position
  end

  test "starts positions at 1 in an empty module" do
    content = create_module.contents.create!(contentable: games(:one))

    assert_equal 1, content.position
  end

  test "cannot add the same game to a module twice" do
    duplicate = content_modules(:one).contents.build(contentable: games(:one))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:contentable_id], "is already in this module"
  end

  test "can add the same game to different modules" do
    content = create_module.contents.build(contentable: games(:one))

    assert content.valid?
  end

  test "destroying a link's content destroys the link" do
    assert_difference [ "Link.count", "Content.count" ], -1 do
      contents(:two).destroy!
    end
  end

  test "destroying a game's content keeps the game" do
    assert_difference "Content.count", -1 do
      assert_no_difference "Game.count" do
        contents(:one).destroy!
      end
    end
  end

  private

  def create_module
    ContentModule.create!(program: programs(:one), level: "basic", name: "Another Module")
  end
end
