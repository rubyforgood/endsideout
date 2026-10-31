require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "delegates to its contentable" do
    game = games(:one)
    content = create_module.contents.create!(contentable: game)

    assert_equal game, content.contentable
    assert_equal "Game", content.contentable_type
  end

  test "belongs to a content module" do
    content_module = create_module
    content = content_module.contents.create!(contentable: games(:one))

    assert_equal content_module, content.content_module
  end

  test "appends new content after the highest position in its module" do
    content_module = create_module
    existing = content_module.contents.create!(contentable: games(:one))

    content = content_module.contents.create!(contentable: games(:two))

    assert_equal existing.position + 1, content.position
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
    order_before = content_modules(:one).contents.map(&:id)

    other.move_up
    other.move_down

    assert_equal 1, other.reload.position
    assert_equal order_before, content_modules(:one).contents.reload.map(&:id)
  end

  test "move works when positions have gaps" do
    contents(:two).update!(position: 5)

    contents(:two).move_up

    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.reload.to_a
  end

  test "move accepts up and down" do
    contents(:one).move("down")
    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.reload.to_a

    contents(:one).move("up")
    assert_equal [ contents(:one), contents(:two) ], content_modules(:one).contents.reload.to_a
  end

  test "move rejects an unknown direction" do
    assert_raises(ArgumentError) { contents(:one).move("sideways") }
  end

  test "cannot add the same game to a module twice" do
    content_module = create_module
    content_module.contents.create!(contentable: games(:one))

    duplicate = content_module.contents.build(contentable: games(:one))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:contentable_id], "is already in this module"
  end

  test "can add the same game to different modules" do
    create_module.contents.create!(contentable: games(:one))

    content = create_module.contents.build(contentable: games(:one))

    assert content.valid?
  end

  test "destroying a link's content destroys the link" do
    content = create_module.contents.create!(contentable: build_link)

    assert_difference [ "Link.count", "Content.count" ], -1 do
      content.destroy!
    end
  end

  test "destroying a game's content keeps the game" do
    content = create_module.contents.create!(contentable: games(:one))

    assert_difference "Content.count", -1 do
      assert_no_difference "Game.count" do
        content.destroy!
      end
    end
  end

  private

  def create_module
    ContentModule.create!(program: programs(:one), level: "basic", name: "Module #{ContentModule.count}")
  end

  def build_link
    Link.new(title: "A Link", url: "https://example.com", link_type: "survey")
  end
end
