require "test_helper"
require "csv"

class StudentCsvImporterTest < ActiveSupport::TestCase
  setup do
    @school = schools(:one)
  end

  test "creates students, teachers and classrooms for the given school" do
    import(<<~CSV)
      Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
      Mae,Jemison,6,Room B,Duke Ellington,dellington@example.com,3D Wellness,moderate
    CSV

    alan = @school.students.find_by!(first_name: "Alan", last_name: "Turing")
    assert_equal 5, alan.grade_level
    assert_equal "Room A", alan.classroom.name
    assert_equal "Nina Simone", alan.classroom.teacher.name
  assert_equal "nsimone@example.com", alan.classroom.teacher.email
    assert_equal @school, alan.classroom.school
    assert_equal @school, alan.classroom.teacher.school
  end

  test "leaves the teacher email blank when the column is empty" do
    import(<<~CSV)
      Alan,Turing,5,Room A,Nina Simone,,Know Your Health,basic
    CSV

    assert_nil @school.teachers.find_by!(name: "Nina Simone").email
  end

  test "reuses one teacher across rows that name the same teacher" do
    assert_difference -> { @school.teachers.count }, 1 do
      import(<<~CSV)
        Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
        Mae,Jemison,6,Room B,Nina Simone,nsimone@example.com,Know Your Health,basic
      CSV
    end
  end

  test "groups students into one classroom per teacher and class name" do
    assert_difference -> { @school.classrooms.count }, 1 do
      import(<<~CSV)
        Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
        Katherine,Johnson,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
      CSV
    end

    room_a = @school.classrooms.find_by!(name: "Room A")
    assert_equal [ "Alan Turing", "Katherine Johnson" ], room_a.students.map(&:full_name).sort
  end

  test "treats the same class name under different teachers as separate classrooms" do
    assert_difference -> { @school.classrooms.count }, 2 do
      import(<<~CSV)
        Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
        Mae,Jemison,6,Room A,Duke Ellington,dellington@example.com,Know Your Health,basic
      CSV
    end
  end

  test "enrolls each classroom in its program at the given level" do
    import(<<~CSV)
      Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
      Mae,Jemison,6,Room B,Duke Ellington,dellington@example.com,3D Wellness,advanced
    CSV

    room_a = @school.classrooms.find_by!(name: "Room A")
    room_b = @school.classrooms.find_by!(name: "Room B")

    assert_equal [ programs(:kyh) ], room_a.programs.to_a
    assert_equal "basic", room_a.classroom_programs.sole.level
    assert_equal [ programs(:"3dw") ], room_b.programs.to_a
    assert_equal "advanced", room_b.classroom_programs.sole.level
  end

  test "reuses an existing program rather than creating a duplicate" do
    assert_no_difference "Program.count" do
      import(<<~CSV)
        Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
      CSV
    end

    assert_equal programs(:kyh), @school.classrooms.find_by!(name: "Room A").programs.sole
  end

  test "creates a program that does not exist yet" do
    assert_difference "Program.count", 1 do
      import(<<~CSV)
        Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Mindful Movement,basic
      CSV
    end

    assert_equal "Mindful Movement", @school.classrooms.find_by!(name: "Room A").programs.sole.name
  end

  test "raises and writes nothing when a student is invalid" do
    assert_no_difference [ "Student.count", "Teacher.count", "Classroom.count", "ClassroomProgram.count" ] do
      error = assert_raises StudentCsvImporter::InvalidStudentError do
        import(<<~CSV)
          Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
          Mae,,6,Room B,Duke Ellington,dellington@example.com,3D Wellness,moderate
        CSV
      end

      assert_match "Last name can't be blank", error.message
    end
  end

  test "raises and writes nothing when a teacher is invalid" do
    assert_no_difference [ "Student.count", "Teacher.count", "Classroom.count" ] do
      error = assert_raises StudentCsvImporter::InvalidTeacherError do
        import(<<~CSV)
          Alan,Turing,5,Room A,,,Know Your Health,basic
        CSV
      end

      assert_match "Name can't be blank", error.message
    end
  end

  test "raises and writes nothing when two rows give different teachers the same email" do
    assert_no_difference [ "Student.count", "Teacher.count", "Classroom.count" ] do
      error = assert_raises StudentCsvImporter::InvalidTeacherError do
        import(<<~CSV)
          Alan,Turing,5,Room A,Nina Simone,shared@example.com,Know Your Health,basic
          Mae,Jemison,6,Room B,Duke Ellington,shared@example.com,3D Wellness,moderate
        CSV
      end

      assert_match "Email has already been taken", error.message
      assert_match "1", error.message
    end
  end

  test "reports the row index of each invalid record" do
    error = assert_raises StudentCsvImporter::InvalidStudentError do
      import(<<~CSV)
        Alan,Turing,5,Room A,Nina Simone,nsimone@example.com,Know Your Health,basic
        Mae,Jemison,,Room B,Duke Ellington,dellington@example.com,3D Wellness,moderate
      CSV
    end

    assert_match "1", error.message
    assert_match "Grade level can't be blank", error.message
  end

  private
    def import(rows, school: @school)
      csv = CSV.parse(Admin::CsvController::CSV_HEADERS.join(",") + "\n" + rows, headers: true)
      StudentCsvImporter.new(csv: csv, school_id: school.id).import
    end
end
