require "test_helper"
require "csv"

class Admin::CsvControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school = schools(:one)
    sign_in_as users(:admin)
  end

  test "should redirect the template download when not authenticated" do
    sign_out

    get school_csv_template_url(@school)

    assert_redirected_to new_session_path
  end

  test "should redirect the import and write nothing when not authenticated" do
    sign_out

    assert_no_difference "Student.count" do
      post school_csv_import_url(@school), params: { file: csv_upload("students.csv") }
    end

    assert_redirected_to new_session_path
  end

  test "should download the student import template" do
    get school_csv_template_url(@school)

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert_equal Admin::CsvController::CSV_HEADERS, CSV.parse(response.body).first
  end

  test "should import students, teachers, classrooms and program enrollments" do
    assert_difference -> { @school.students.count } => 3,
                      -> { @school.teachers.count } => 2,
                      -> { @school.classrooms.count } => 2,
                      -> { ClassroomProgram.count } => 2 do
      post school_csv_import_url(@school), params: { file: csv_upload("students.csv") }
    end

    assert_redirected_to school_students_path(@school)
    assert_equal "Students were successfully imported.", flash[:notice]

    room_a = @school.classrooms.find_by(name: "Room A")
    assert_equal "Nina Simone", room_a.teacher.name
    assert_equal [ "Alan Turing", "Katherine Johnson" ], room_a.students.map(&:full_name).sort
    assert_equal [ programs(:kyh) ], room_a.programs.to_a
    assert_equal [ "basic" ], room_a.classroom_programs.map(&:level)
  end

  test "should import into the school named in the route" do
    other_school = schools(:two)

    post school_csv_import_url(other_school), params: { file: csv_upload("students.csv") }

    assert_redirected_to school_students_path(other_school)
    assert other_school.students.exists?(first_name: "Alan", last_name: "Turing")
    assert_not @school.students.exists?(first_name: "Alan", last_name: "Turing")
  end

  test "should reject a student who already belongs to the school" do
    assert_no_difference "Student.count" do
      post school_csv_import_url(@school), params: { file: csv_upload("students_existing_student.csv") }
    end

    assert_redirected_to school_students_path(@school)
    assert_equal "Student: Ada Lovelace already exists", flash[:alert]
  end

  test "should reject a classroom that already belongs to the school" do
    assert_no_difference "Classroom.count" do
      post school_csv_import_url(@school), params: { file: csv_upload("students_existing_classroom_name.csv") }
    end

    assert_redirected_to school_students_path(@school)
    assert_equal "Classroom: Classroom 1 already exists", flash[:alert]
  end

  test "should allow a classroom name that is only taken at another school" do
    other_school = schools(:two)

    assert_difference -> { other_school.classrooms.count }, 1 do
      post school_csv_import_url(other_school), params: { file: csv_upload("students_existing_classroom_name.csv") }
    end

    assert_equal "Students were successfully imported.", flash[:notice]
  end

  test "should reject headers that do not match the template" do
    assert_no_difference "Student.count" do
      post school_csv_import_url(@school), params: { file: csv_upload("students_bad_headers.csv") }
    end

    assert_redirected_to school_students_path(@school)
    assert_equal "Headers must match CSV headers", flash[:alert]
  end

  # An extra field widens the parsed header row, so this trips the header check
  # rather than the per-row column count check.
  test "should reject a row with more columns than the template" do
    assert_no_difference "Student.count" do
      post school_csv_import_url(@school), params: { file: csv_upload("students_extra_column.csv") }
    end

    assert_redirected_to school_students_path(@school)
    assert_equal "Headers must match CSV headers", flash[:alert]
  end

  test "should report two rows giving different teachers the same email" do
    assert_no_difference [ "Student.count", "Teacher.count" ] do
      post school_csv_import_url(@school), params: { file: csv_upload("students_duplicate_teacher_email.csv") }
    end

    assert_redirected_to school_students_path(@school)
    assert_match "Email has already been taken", flash[:alert]
  end

  test "should report validation errors and write nothing" do
    assert_no_difference [ "Student.count", "Teacher.count", "Classroom.count" ] do
      post school_csv_import_url(@school), params: { file: csv_upload("students_missing_grade_level.csv") }
    end

    assert_redirected_to school_students_path(@school)
    assert_equal "Row 2: Grade level can't be blank", flash[:alert]
  end

  test "should report a missing file" do
    assert_no_difference "Student.count" do
      post school_csv_import_url(@school)
    end

    assert_redirected_to school_students_path(@school)
    assert_equal "Choose a CSV file to import.", flash[:alert]
  end

  test "should 404 for an unknown school" do
    assert_no_difference "Student.count" do
      post school_csv_import_url(school_id: 0), params: { file: csv_upload("students.csv") }
    end

    assert_response :not_found
  end

  private
    def csv_upload(name)
      fixture_file_upload(name, "text/csv")
    end
end
