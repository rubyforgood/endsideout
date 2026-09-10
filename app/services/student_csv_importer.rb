

class StudentCsvImporter
  class InvalidClassroomError < StandardError; end
  class InvalidStudentError < StandardError; end
  class InvalidTeacherError < StandardError; end

  def initialize(csv:, school_id:)
    @csv = csv
    @school_id = school_id
    @error_messages = {
      classrooms: {},
      teachers: {},
      students: {}
    }
    @classrooms = {}
    @teachers = {}
    @students = []
  end


  def import
    @csv.each_with_index do |row, index|
      next if row.blank?

      teacher = find_or_build_teacher(row)
      classroom = find_or_build_classroom(row, teacher)

      student = Student.new(
        first_name: row['Student First Name'],
        last_name: row['Student Last Name'],
        grade_level: row['Grade Level'],
        school_id: @school_id,
        classroom: classroom
      )

      collect_errors(:teachers, teacher, index)
      collect_errors(:classrooms, classroom, index)
      collect_errors(:students, student, index)

      @students << student
    end

    save_records
  end



private

  def save_records
    ActiveRecord::Base.transaction do
      raise_validation_errors!

      @teachers.each_value(&:save!)
      @classrooms.each_value(&:save!)
      @students.each(&:save!)

      create_program_associations
    end
  end

  def create_program_associations
    @csv.each do |row|
      teacher = @teachers[row["Teacher"]]
      classroom = @classrooms[[teacher.name, row["Class Name"]]]

      program = Program.create_or_find_by!(name: row['Program'])

      classroom.classroom_programs.create_or_find_by!(program: program, level: row['Program Level'])
    end

  end
  def collect_errors(type, record, index)
    return if record.valid?

    @error_messages[type][index] = record.errors.full_messages
  end

  def raise_validation_errors!
    raise InvalidClassroomError, @error_messages[:classrooms].to_s if @error_messages[:classrooms].any?
    raise InvalidStudentError, @error_messages[:students].to_s if @error_messages[:students].any?
    raise InvalidTeacherError, @error_messages[:teachers].to_s if @error_messages[:teachers].any?
  end

  def find_or_build_teacher(row)
    @teachers[row["Teacher"]] ||= Teacher.new(
      name: row["Teacher"],
      school_id: @school_id
    )
  end

  def find_or_build_classroom(row, teacher)
    key = [teacher.name, row["Class Name"]]

    @classrooms[key] ||= Classroom.new(
      school_id: @school_id,
      name: row["Class Name"],
      teacher: teacher
    )
  end
end