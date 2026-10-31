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
    link = Link.new(title: "A Link", url: "https://example.com", link_type: "survey")
    content_module.contents.create!(contentable: link)

    assert_difference "Link.count", -1 do
      content_module.destroy!
    end
  end

  test "available games exclude games already in the module" do
    assert_not_includes content_modules(:one).available_games, games(:one)
  end

  test "available games include games only in another module" do
    other_module = ContentModule.create!(program: @program, level: "basic", name: "Other Module")
    other_module.contents.create!(contentable: games(:two))

    assert_includes content_modules(:one).available_games, games(:two)
  end

  test "available games include unattached games" do
    assert_includes content_modules(:one).available_games, games(:two)
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
end
