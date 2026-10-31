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

  test "edit lists links ordered by position" do
    content_module = ContentModule.create!(program: programs(:one), level: "basic", name: "Ordered Module")
    last = content_module.contents.create!(contentable: Link.new(title: "Last Link", url: "https://example.com/2", link_type: "survey"))
    first = content_module.contents.create!(contentable: Link.new(title: "First Link", url: "https://example.com/1", link_type: "survey"))
    first.move(:up)

    get edit_admin_content_module_url(content_module)

    row_ids = css_select("tbody tr").map { |row| row["id"] }
    assert_equal [ dom_id(first), dom_id(last) ], row_ids
  end

  test "edit disables moving the first row up and the last row down" do
    get edit_admin_content_module_url(@content_module)

    assert_select "##{dom_id(contents(:one))} button[aria-label$='up'][disabled]", count: 1
    assert_select "##{dom_id(contents(:one))} button[aria-label$='down'][disabled]", count: 0
    assert_select "##{dom_id(contents(:two))} button[aria-label$='down'][disabled]", count: 1
    assert_select "##{dom_id(contents(:two))} button[aria-label$='up'][disabled]", count: 0
  end

  test "index disables moving the first module up and the last module down within a level" do
    first = @content_module
    second = ContentModule.create!(program: first.program, level: first.level, name: "Second Module")

    get admin_content_modules_url(program_id: first.program_id)

    assert_select "##{dom_id(first)}" do
      assert_select "button[aria-label='Move #{first.name} up'][disabled]", count: 1
      assert_select "button[aria-label='Move #{first.name} down'][disabled]", count: 0
    end
    assert_select "##{dom_id(second)}" do
      assert_select "button[aria-label='Move #{second.name} down'][disabled]", count: 1
      assert_select "button[aria-label='Move #{second.name} up'][disabled]", count: 0
    end
  end

  test "index disables both move buttons for the only module in a level" do
    only = ContentModule.create!(program: programs(:one), level: "moderate", name: "Only Moderate")

    get admin_content_modules_url(program_id: programs(:one).id)

    assert_select "##{dom_id(only)}" do
      assert_select "button[aria-label='Move #{only.name} up'][disabled]", count: 1
      assert_select "button[aria-label='Move #{only.name} down'][disabled]", count: 1
    end
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
