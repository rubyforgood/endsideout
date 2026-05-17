require "test_helper"

class ContentModuleTest < ActiveSupport::TestCase
  test "is valid with required fields" do
    mod = ContentModule.new(program: programs(:kyh), level: "basic", name: "Test Module")
    assert mod.valid?
  end

  test "is invalid without a name" do
    mod = ContentModule.new(program: programs(:kyh), level: "basic")
    assert_not mod.valid?
    assert_includes mod.errors[:name], "can't be blank"
  end

  test "is invalid without a level" do
    mod = ContentModule.new(program: programs(:kyh), name: "Test Module")
    assert_not mod.valid?
  end

  test "is invalid without a program" do
    mod = ContentModule.new(level: "basic", name: "Test Module")
    assert_not mod.valid?
  end

  test "destroys associated links" do
    mod = content_modules(:intro)
    assert_difference "Link.count", -mod.links.count do
      mod.destroy!
    end
  end
end
