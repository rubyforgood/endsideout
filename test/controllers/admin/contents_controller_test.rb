require "test_helper"

class Admin::ContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @content_module = content_modules(:one)
    sign_in_as users(:one)
  end

  test "create attaches an existing game to the module" do
    game = games(:two)

    assert_difference -> { @content_module.contents.count }, 1 do
      post admin_content_module_contents_url(@content_module), params: { content: { contentable_id: game.id } }
    end

    assert_redirected_to edit_admin_content_module_url(@content_module)
    assert_equal game, @content_module.contents.last.contentable
  end

  test "create does not attach the same game twice" do
    game = games(:one)

    assert_no_difference "Content.count" do
      post admin_content_module_contents_url(@content_module), params: { content: { contentable_id: game.id } }
    end

    assert_redirected_to edit_admin_content_module_url(@content_module)
    follow_redirect!
    assert_select "p", text: /already been taken/
  end

  test "create responds not found for an unknown game" do
    assert_no_difference "Content.count" do
      post admin_content_module_contents_url(@content_module), params: { content: { contentable_id: 0 } }
    end
    assert_response :not_found
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

  test "requires admin sign in" do
    sign_out

    assert_no_difference "Content.count" do
      delete admin_content_url(contents(:one))
    end
    assert_redirected_to new_admin_session_url
  end
end
