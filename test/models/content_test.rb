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

  test "move_up swaps position with the previous content" do
    contents(:two).move_up

    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.reload.to_a
    assert_equal [ 1, 2 ], content_modules(:one).contents.map(&:position)
  end

  test "move_down swaps position with the next content" do
    contents(:one).move_down

    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.reload.to_a
  end

  test "move_up does nothing for the first content" do
    contents(:one).move_up

    assert_equal [ 1, 2 ], [ contents(:one).reload.position, contents(:two).reload.position ]
  end

  test "move_down does nothing for the last content" do
    contents(:two).move_down

    assert_equal [ 1, 2 ], [ contents(:one).reload.position, contents(:two).reload.position ]
  end

  test "moving ignores contents in other modules" do
    other = create_module.contents.create!(contentable: games(:one))

    other.move_up
    other.move_down

    assert_equal 1, other.reload.position
    assert_equal 1, contents(:one).reload.position
  end

  test "cannot add the same game to a module twice" do
    duplicate = content_modules(:one).contents.build(contentable: games(:one))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:contentable_id], "has already been taken"
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
