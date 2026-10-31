require "test_helper"

class LinkTest < ActiveSupport::TestCase
  test "is valid with required fields" do
    link = Link.new(title: "My Link", url: "https://example.com", link_type: "survey")
    assert link.valid?
  end

  test "is invalid without a title" do
    link = Link.new(url: "https://example.com", link_type: "survey")
    assert_not link.valid?
    assert_includes link.errors[:title], "can't be blank"
  end

  test "is invalid without a url" do
    link = Link.new(title: "My Link", link_type: "survey")
    assert_not link.valid?
    assert_includes link.errors[:url], "can't be blank"
  end

  test "destroying a link destroys its content" do
    content_id = contents(:two).id

    assert_difference [ "Link.count", "Content.count" ], -1 do
      links(:one).destroy!
    end
    assert_nil Content.find_by(id: content_id)
  end

  test "finds its content module through its content" do
    assert_equal content_modules(:one), links(:one).content_module
  end

  test "is invalid without a link_type" do
    link = Link.new(title: "My Link", url: "https://example.com")
    assert_not link.valid?
  end
end
