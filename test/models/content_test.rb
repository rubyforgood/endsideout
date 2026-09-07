require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "delegates to its contentable" do
    content = contents(:one)

    assert_equal games(:one), content.contentable
    assert_equal "Game", content.contentable_type
  end

  test "belongs to a content module" do
    content = contents(:two)

    assert_equal content_modules(:intro), content.content_module
  end
end
