require "application_system_test_case"

class StudentAccessibilityTest < ApplicationSystemTestCase
  test "student home page is accessible" do
    student = students(:ada)
    classroom = classrooms(:one)

    # Login as student
    visit new_student_session_path(classroom_uuid: classroom.uuid, student_id: student.id)
    
    # Verify we are on the student home page
    assert_selector "h1", text: "Welcome to EndsideOut"
    
    # Check accessibility
    assert_accessible
  end
end
