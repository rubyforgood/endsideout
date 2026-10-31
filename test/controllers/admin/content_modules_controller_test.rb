require "test_helper"

class Admin::ContentModulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @content_module = content_modules(:one)
    sign_in_as users(:one)
  end

  test "should get index" do
    get admin_content_modules_url
    assert_response :success
  end

  test "index marks the active program tab as selected" do
    program = programs(:one)
    get admin_content_modules_url(program_id: program.id)
    assert_select "a[role='tab'][aria-selected='true'][href*='program_id=#{program.id}']"
  end

  test "should get new" do
    get new_admin_content_module_url
    assert_response :success
  end

  test "should create content module" do
    assert_difference "ContentModule.count" do
      post admin_content_modules_url, params: {
        content_module: { name: "New Module", program_id: programs(:one).id, level: "moderate", position: 1 }
      }
    end
    assert_redirected_to admin_content_modules_url
  end

  test "should not create with missing name" do
    assert_no_difference "ContentModule.count" do
      post admin_content_modules_url, params: {
        content_module: { name: "", program_id: programs(:one).id, level: "basic" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_admin_content_module_url(@content_module)
    assert_response :success
  end

  test "edit lists links and games in content position order" do
    contents(:one).update!(position: 2)
    contents(:two).update!(position: 1)

    get edit_admin_content_module_url(@content_module)

    titles = css_select("table tbody tr td:first-child").map { |cell| cell.text.strip }
    assert_equal [ "Health Survey ↗", "Game 1" ], titles
    assert_select "table a[target=_blank][rel='noopener noreferrer']", text: "Health Survey ↗"
  end

  test "edit offers only games not yet in the module" do
    get edit_admin_content_module_url(@content_module)

    assert_select "select[name='content[contentable_id]'] option", count: 1, text: games(:two).title
  end

  test "edit hides the add game form when every game is attached" do
    Content.create!(content_module: @content_module, contentable: games(:two))

    get edit_admin_content_module_url(@content_module)

    assert_select "select[name='content[contentable_id]']", count: 0
  end

  test "index shows the contents count" do
    get admin_content_modules_url(program_id: @content_module.program_id)

    assert_select "th", text: "Contents"
    assert_select "tbody tr", text: /#{@content_module.name}\s+#{@content_module.contents.count}/
  end

  test "should update content module" do
    patch admin_content_module_url(@content_module), params: {
      content_module: { name: "Updated Name" }
    }
    assert_redirected_to admin_content_modules_url
    assert_equal "Updated Name", @content_module.reload.name
  end

  test "should destroy content module" do
    content_module = ContentModule.create!(program: programs(:one), level: "basic", name: "To Delete")
    assert_difference "ContentModule.count", -1 do
      delete admin_content_module_url(content_module)
    end
    assert_redirected_to admin_content_modules_url
  end

  test "should not destroy content module assigned to classrooms" do
    assert_no_difference "ContentModule.count" do
      delete admin_content_module_url(@content_module)
    end
    assert_redirected_to admin_content_modules_url
    assert_equal "Cannot delete a module that has been assigned to classrooms.", flash[:alert]
  end
end
