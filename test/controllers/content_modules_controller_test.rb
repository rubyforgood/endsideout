require "test_helper"

class ContentModulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mod = content_modules(:intro)
    sign_in_as users(:admin)
  end

  test "should get index" do
    get content_modules_url
    assert_response :success
  end

  test "should get new" do
    get new_content_module_url
    assert_response :success
  end

  test "should create content module" do
    assert_difference "ContentModule.count" do
      post content_modules_url, params: {
        content_module: { name: "New Module", program_id: programs(:kyh).id, level: "moderate", position: 1 }
      }
    end
    assert_redirected_to content_modules_url
  end

  test "should not create with missing name" do
    assert_no_difference "ContentModule.count" do
      post content_modules_url, params: {
        content_module: { name: "", program_id: programs(:kyh).id, level: "basic" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_content_module_url(@mod)
    assert_response :success
  end

  test "should update content module" do
    patch content_module_url(@mod), params: {
      content_module: { name: "Updated Name" }
    }
    assert_redirected_to content_modules_url
    assert_equal "Updated Name", @mod.reload.name
  end

  test "should destroy content module" do
    mod = content_modules(:advanced_wellness)
    assert_difference "ContentModule.count", -1 do
      delete content_module_url(mod)
    end
    assert_redirected_to content_modules_url
  end
end
