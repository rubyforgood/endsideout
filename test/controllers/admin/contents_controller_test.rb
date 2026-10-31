require "test_helper"

class Admin::ContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @content_module = content_modules(:one)
    sign_in_as users(:one)
  end

  test "destroy removes a game from the module but keeps the game" do
    content = contents(:one)

    assert_difference "Content.count", -1 do
      assert_no_difference "Game.count" do
        delete admin_content_url(content)
      end
    end

    assert_redirected_to edit_admin_content_module_url(@content_module)
  end

  test "destroy deletes the link behind a link content" do
    content = contents(:two)

    assert_difference [ "Content.count", "Link.count" ], -1 do
      delete admin_content_url(content)
    end

    assert_redirected_to edit_admin_content_module_url(@content_module)
  end

  test "destroy requires admin sign in" do
    sign_out

    assert_no_difference "Content.count" do
      delete admin_content_url(contents(:one))
    end
    assert_redirected_to new_admin_session_url
  end
end
