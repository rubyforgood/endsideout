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
        content_module: { name: "New Module", program_id: programs(:one).id, level: "moderate" }
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

<<<<<<< HEAD
  test "edit lists links ordered by position" do
    content_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Ordered Module")
    last, first = [
      content_module.contents.create!(contentable: Link.new(title: "Last Link", url: "https://example.com/2", link_type: "survey",), position: 2),
      content_module.contents.create!(contentable: Link.new(title: "First Link", url: "https://example.com/1", link_type: "survey"),  position: 1)
    ]

    get edit_admin_content_module_url(content_module)

    row_ids = css_select("tbody tr").map { |row| row["id"] }
    assert_equal [ dom_id(first), dom_id(last) ], row_ids
  end

  test "edit opens links in a new tab without opener access" do
    get edit_admin_content_module_url(@content_module)

    assert_select "##{dom_id(contents(:two))} a[target=_blank][rel='noopener noreferrer']", text: "Health Survey ↗"
  end

  test "edit offers to delete a link" do
    get edit_admin_content_module_url(@content_module)

    assert_select "##{dom_id(contents(:two))}" do
      assert_select "button[data-turbo-confirm='Delete this link? It will be removed from the module and deleted.']", text: "Delete"
    end
  end

  test "edit offers to remove a game" do
    get edit_admin_content_module_url(@content_module)

    assert_select "##{dom_id(contents(:one))}" do
      assert_select "button[data-turbo-confirm='Remove this game from the module? The game itself is kept.']", text: "Remove"
    end
  end

  test "index shows the contents count" do
    get admin_content_modules_url(program_id: @content_module.program_id)

    assert_select "th", text: "Contents"
    assert_select "##{dom_id(@content_module)} td:nth-child(2)", text: "2"
  end

  test "create appends the module and ignores a submitted position" do
    ContentModule.create!(program: programs(:one), level: "moderate", name: "Existing")

    post admin_content_modules_url, params: {
      content_module: { name: "New Module", program_id: programs(:one).id, level: "moderate", position: 99 }
    }

    assert_equal 2, ContentModule.find_by!(name: "New Module").position
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
