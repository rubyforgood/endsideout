require "test_helper"

class Admin::ContentModules::PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @program = programs(:one)
    ClassroomModule.where(content_module: @program.content_modules).destroy_all
    @program.content_modules.destroy_all
    @first = create_module("First")
    @second = create_module("Second")
    sign_in_as users(:one)
  end

  test "moves module down" do
    patch admin_content_module_position_url(@first), params: { direction: "down" }

    assert_redirected_to admin_content_modules_url(program_id: @program.id)
    assert_equal [ @second.id, @first.id ], ordered_ids
  end

  test "moves module up" do
    patch admin_content_module_position_url(@second), params: { direction: "up" }

    assert_redirected_to admin_content_modules_url(program_id: @program.id)
    assert_equal [ @second.id, @first.id ], ordered_ids
  end

  test "moving the first module up changes nothing" do
    patch admin_content_module_position_url(@first), params: { direction: "up" }

    assert_redirected_to admin_content_modules_url(program_id: @program.id)
    assert_equal [ @first.id, @second.id ], ordered_ids
  end

  test "rejects an unknown direction" do
    patch admin_content_module_position_url(@first), params: { direction: "sideways" }

    assert_response :unprocessable_entity
    assert_equal [ @first.id, @second.id ], ordered_ids
  end

  test "requires admin sign in" do
    sign_out

    patch admin_content_module_position_url(@first), params: { direction: "down" }

    assert_redirected_to new_admin_session_url
    assert_equal [ @first.id, @second.id ], ordered_ids
  end

  private

  def create_module(name)
    ContentModule.create!(program: @program, level: "advanced", name: name)
  end

  def ordered_ids
    @program.content_modules.ordered.map(&:id)
  end
end
