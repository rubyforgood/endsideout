require "test_helper"

class ClassroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @classroom = classrooms(:one)
    sign_in_as users(:admin)
  end

  test "should get edit" do
    get edit_classroom_url(@classroom)
    assert_response :success
  end

  test "should update classroom name and teacher" do
    patch classroom_url(@classroom), params: { classroom: { name: "Updated Name", teacher: "New Teacher" } }
    assert_redirected_to school_students_url(@classroom.school)
    assert_equal "Updated Name", @classroom.reload.name
  end

  test "should add a program enrollment" do
    program = programs(:"3dw")

    assert_difference "ClassroomProgram.count" do
      patch classroom_url(@classroom), params: {
        classroom: {
          name: @classroom.name,
          classroom_programs_attributes: [ { program_id: program.id, level: "moderate" } ]
        }
      }
    end

    assert_redirected_to school_students_url(@classroom.school)
    assert @classroom.classroom_programs.exists?(program: program, level: "moderate")
  end

  test "should update an existing enrollment level" do
    cp = classroom_programs(:one)

    patch classroom_url(@classroom), params: {
      classroom: {
        name: @classroom.name,
        classroom_programs_attributes: [ { id: cp.id, program_id: cp.program_id, level: "advanced" } ]
      }
    }

    assert_redirected_to school_students_url(@classroom.school)
    assert_equal "advanced", cp.reload.level
  end

  test "should remove an enrollment" do
    cp = classroom_programs(:one)
    # Add a second enrollment so the classroom still has one after removal
    @classroom.classroom_programs.create!(program: programs(:"3dw"), level: "basic")

    assert_difference "ClassroomProgram.count", -1 do
      patch classroom_url(@classroom), params: {
        classroom: {
          name: @classroom.name,
          classroom_programs_attributes: [ { id: cp.id, _destroy: "1" } ]
        }
      }
    end

    assert_redirected_to school_students_url(@classroom.school)
  end

  test "is invalid when removing all programs" do
    cp = classroom_programs(:one)

    assert_no_difference "ClassroomProgram.count" do
      patch classroom_url(@classroom), params: {
        classroom: {
          name: @classroom.name,
          classroom_programs_attributes: [ { id: cp.id, _destroy: "1" } ]
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "is invalid when a program is selected without a level" do
    program = programs(:"3dw")

    assert_no_difference "ClassroomProgram.count" do
      patch classroom_url(@classroom), params: {
        classroom: {
          name: @classroom.name,
          classroom_programs_attributes: [ { program_id: program.id, level: "" } ]
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
