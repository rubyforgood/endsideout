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

  test "edit lists links and games in content position order" do
    contents(:one).update!(position: 2)
    contents(:two).update!(position: 1)

    get edit_admin_content_module_url(@content_module)

    titles = css_select("table tbody tr td:first-child").map { |cell| cell.text.strip }
    assert_equal [ "Health Survey ↗", "Game 1" ], titles
    assert_select "table a[target=_blank][rel='noopener noreferrer']", text: "Health Survey ↗"
  end

  test "edit disables moving the first row up and the last row down" do
    get edit_admin_content_module_url(@content_module)

    assert_select "tbody tr:first-child button[aria-label$='up'][disabled]", count: 1
    assert_select "tbody tr:first-child button[aria-label$='down'][disabled]", count: 0
    assert_select "tbody tr:last-child button[aria-label$='down'][disabled]", count: 1
    assert_select "tbody tr:last-child button[aria-label$='up'][disabled]", count: 0
  end

  test "edit offers only games not yet in the module" do
    get edit_admin_content_module_url(@content_module)

    assert_select "select[name='content[contentable_id]'] option", count: 1, text: games(:two).title
  end

  test "edit hides the add game form when every game is attached" do
    Content.create!(content_module: @content_module, contentable: games(:two))

    get edit_admin_content_module_url(@content_module)

    assert_select "select[name='content[contentable_id]']", count: 0
    assert_select "p", text: /All games are in this module\./
  end

  test "edit links to creating a game when no games exist" do
    Content.where(contentable_type: "Game").destroy_all
    Game.destroy_all

    get edit_admin_content_module_url(@content_module)

    assert_select "select[name='content[contentable_id]']", count: 0
    assert_select "p", text: /No games yet/
    assert_select "a.link[href='#{new_admin_game_path}']", text: "Create a game"
  end

  test "index shows the contents count" do
    get admin_content_modules_url(program_id: @content_module.program_id)

    assert_select "th", text: "Contents"
    assert_select "tbody tr", text: /#{@content_module.name}\s+#{@content_module.contents.count}/
  end

  test "index disables moving the first module up and the last module down within a level" do
    second = ContentModule.create!(program: programs(:one), level: "basic", name: "Second Basic")
    ContentModule.create!(program: programs(:one), level: "moderate", name: "Only Moderate")

    get admin_content_modules_url(program_id: programs(:one).id)

    assert_select "section", text: /Basic/ do
      assert_select "tbody tr:first-child button[aria-label$='up'][disabled]", count: 1
      assert_select "tbody tr:first-child button[aria-label$='down'][disabled]", count: 0
      assert_select "tbody tr:last-child button[aria-label='Move #{second.name} down'][disabled]", count: 1
      assert_select "tbody tr:last-child button[aria-label$='up'][disabled]", count: 0
    end
    assert_select "section", text: /Moderate/ do
      assert_select "tbody tr button[disabled]", count: 2
    end
  end

  test "index move buttons patch the module position" do
    get admin_content_modules_url(program_id: @content_module.program_id)

    assert_select "form[action='#{admin_content_module_position_path(@content_module)}'] button[aria-label='Move #{@content_module.name} up']"
  end

  test "create appends the module and ignores a submitted position" do
    ContentModule.create!(program: programs(:one), level: "moderate", name: "Existing")

    post admin_content_modules_url, params: {
      content_module: { name: "New Module", program_id: programs(:one).id, level: "moderate", position: 99 }
    }

    assert_equal 2, ContentModule.find_by!(name: "New Module").position
  end

  test "form has no position field" do
    get new_admin_content_module_url

    assert_select "input[name='content_module[position]']", count: 0
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
