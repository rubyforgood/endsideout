require "test_helper"

class ContentModuleTest < ActiveSupport::TestCase
  setup do
    @program = programs(:one)
  end

  test "is valid with required fields" do
    content_module = ContentModule.new(program: @program, level: "basic", name: "Test Module")
    assert content_module.valid?
  end

  test "is invalid without a name" do
    content_module = ContentModule.new(program: @program, level: "basic")
    assert_not content_module.valid?
    assert_includes content_module.errors[:name], "can't be blank"
  end

  test "is invalid without a level" do
    content_module = ContentModule.new(program: @program, name: "Test Module")
    assert_not content_module.valid?
  end

  test "is invalid without a program" do
    content_module = ContentModule.new(level: "basic", name: "Test Module")
    assert_not content_module.valid?
  end

  test "destroys associated links" do
    content_module = ContentModule.create!(program: @program, level: "basic", name: "With Links")
    link = Link.create!(content_module: content_module, title: "A Link", url: "https://example.com", link_type: "survey")
    Content.create!(content_module: content_module, contentable: link)

    assert_difference "Link.count", -1 do
      content_module.destroy!
    end
  end

  test "exposes delegated contentables" do
    assert_equal [ links(:one) ], content_modules(:one).links.to_a
    assert_equal [ games(:one) ], content_modules(:one).games.to_a
  end

  test "returns contents ordered by position" do
    contents(:one).update!(position: 2)
    contents(:two).update!(position: 1)

    assert_equal [ contents(:two), contents(:one) ], content_modules(:one).contents.to_a
  end

  test "appends new modules after the highest position in their program and level" do
    first = create_module("First")
    second = create_module("Second")

    assert_equal [ 1, 2 ], [ first.position, second.position ]
  end

  test "positions are separate for each level and program" do
    create_module("Advanced")
    moderate = create_module("Moderate", level: "moderate")
    other_program = create_module("Other", program: programs(:two))

    assert_equal 1, moderate.position
    assert_equal 1, other_program.position
  end

  test "keeps an explicit position" do
    assert_equal 7, create_module("Explicit", position: 7).position
  end

  test "moves to the end of its new level when the level changes" do
    mod = create_module("Advanced")
    create_module("Moderate", level: "moderate")

    mod.update!(level: "moderate")

    assert_equal 2, mod.position
  end

  test "moves to the end of its new program when the program changes" do
    mod = create_module("Advanced")
    create_module("Other", program: programs(:two))

    mod.update!(program: programs(:two))

    assert_equal 2, mod.position
  end

  test "keeps its position when other fields change" do
    first = create_module("First")
    create_module("Second")

    first.update!(name: "Renamed")

    assert_equal 1, first.reload.position
  end

  test "move_up swaps position with the previous module" do
    first = create_module("First")
    second = create_module("Second")

    second.move_up

    assert_equal [ second, first ], ordered_advanced_modules
  end

  test "move_down swaps position with the next module" do
    first = create_module("First")
    second = create_module("Second")

    first.move_down

    assert_equal [ second, first ], ordered_advanced_modules
  end

  test "move_up and move_down do nothing at the ends" do
    first = create_module("First")
    second = create_module("Second")

    first.move_up
    second.move_down

    assert_equal [ first, second ], ordered_advanced_modules
  end

  test "moving ignores modules in other levels and programs" do
    only = create_module("Only")
    create_module("Moderate", level: "moderate")
    create_module("Other", program: programs(:two))

    only.move_up
    only.move_down

    assert_equal 1, only.reload.position
  end

  test "cannot be destroyed when classroom modules exist" do
    content_module = ContentModule.create!(program: @program, level: "basic", name: "Assigned Module")
    classroom_program = classroom_programs(:one)
    classroom_program.classroom_modules.create!(content_module: content_module)

    assert_not content_module.destroy
    assert content_module.persisted?
  end

  private

  # Defaults to a level no fixture uses, so positions start empty.
  def create_module(name, program: @program, level: "advanced", **attributes)
    ContentModule.create!(program: program, level: level, name: name, **attributes)
  end

  def ordered_advanced_modules
    @program.content_modules.advanced.ordered.to_a
  end
end
