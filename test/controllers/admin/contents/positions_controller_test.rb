require "test_helper"

class Admin::Contents::PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @content_module = content_modules(:one)
    @first = contents(:one)
    @second = contents(:two)
    sign_in_as users(:one)
  end

  test "moves content down" do
    patch admin_content_position_url(@first), params: { direction: "down" }

    assert_redirected_to edit_admin_content_module_url(@content_module)
    assert_equal [ @second.id, @first.id ], @content_module.contents.reload.map(&:id)
  end

  test "moves content up" do
    patch admin_content_position_url(@second), params: { direction: "up" }

    assert_redirected_to edit_admin_content_module_url(@content_module)
    assert_equal [ @second.id, @first.id ], @content_module.contents.reload.map(&:id)
  end

  test "moving the first content up changes nothing" do
    patch admin_content_position_url(@first), params: { direction: "up" }

    assert_redirected_to edit_admin_content_module_url(@content_module)
    assert_equal [ @first.id, @second.id ], @content_module.contents.reload.map(&:id)
  end

  test "rejects an unknown direction" do
    patch admin_content_position_url(@first), params: { direction: "sideways" }

    assert_response :unprocessable_entity
    assert_equal [ @first.id, @second.id ], @content_module.contents.reload.map(&:id)
  end

  test "requires admin sign in" do
    sign_out

    patch admin_content_position_url(@first), params: { direction: "down" }

    assert_redirected_to new_admin_session_url
    assert_equal [ @first.id, @second.id ], @content_module.contents.reload.map(&:id)
  end
end
