require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "delegates to its contentable" do
    game = games(:one)
    content = create_module.contents.create!(contentable: game)

    assert_equal game, content.contentable
    assert_equal "Game", content.contentable_type
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
    contents(:one).update!(position: 1)
    contents(:two).update!(position: 2)

    assert_changes -> { contents(:two).position }, from: 2, to: 1 do
      contents(:two).move_up
    end

    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.reload.to_a
  end

  test "move_down swaps position with the next content" do
    contents(:one).update!(position: 1)
    contents(:two).update!(position: 2)

    assert_changes -> { contents(:one).position }, from: 1, to: 2 do
      contents(:one).move_down
    end

    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.reload.to_a
  end

  test "move_up does nothing for the first content" do
    contents(:one).update!(position: 1)
    contents(:two).update!(position: 2)

    assert_no_difference -> { contents(:one).position } do
      contents(:one).move_up
    end

    assert_equal [ 1, 2 ], [ contents(:one).reload.position, contents(:two).reload.position ]
  end

  test "move_down does nothing for the last content" do
    contents(:one).update!(position: 1)
    contents(:two).update!(position: 2)

    contents(:two).move_down

    assert_equal [ 1, 2 ], [ contents(:one).reload.position, contents(:two).reload.position ]
  end

  test "moving ignores contents in other modules" do
    contents(:one).update!(position: 1)
    contents(:two).update!(position: 2)
    other = create_module.contents.create!(contentable: games(:one))

    assert_no_changes -> { content_modules(:one).contents.map(&:id) } do
      other.move_up
      other.move_down
    end
  end

  test "move accepts up and down" do
    contents(:one).update!(position: 1)
    contents(:two).update!(position: 2)

    contents(:one).move(:down)
    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.reload.to_a

    contents(:one).move(:up)
    assert_equal [ contents(:one), contents(:two) ], content_modules(:one).contents.reload.to_a
  end

  test "move rejects an unknown direction" do
    assert_raises(ArgumentError) { contents(:one).move(:sideways) }
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
