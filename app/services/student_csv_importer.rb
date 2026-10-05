

class StudentCsvImporter
  class InvalidClassroomError < StandardError; end
  class InvalidProgramError < StandardError; end
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
    @row_indexes = {}
  end


  def import
    @csv.each_with_index do |row, index|
      next if row.blank?

      teacher = find_or_build_teacher(row)
      classroom = find_or_build_classroom(row, teacher)

      student = Student.new(
        first_name: row["Student First Name"],
        last_name: row["Student Last Name"],
        grade_level: row["Grade Level"],
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

      save_all(@teachers.values, InvalidTeacherError)
      save_all(@classrooms.values, InvalidClassroomError)
      save_all(@students, InvalidStudentError)

      create_program_associations
    end
  end

  # A uniqueness collision between two rows of the same file survives `valid?`,
  # because neither record is persisted yet. Re-raise it in the shape the
  # validation errors already use so callers only have to handle one thing.
  def save_all(records, error_class)
    records.each do |record|
      record.save!
    rescue ActiveRecord::RecordInvalid => error
      raise error_class, { @row_indexes[record.object_id] => error.record.errors.full_messages }.to_s
    end
  end

  def create_program_associations
    @csv.each do |row|
      teacher = @teachers[row["Teacher"]]
      classroom = @classrooms[[ teacher.name, row["Class Name"] ]]

      program = find_existing_program!(row["Program"])

      classroom.classroom_programs.create_or_find_by!(program: program, level: row["Program Level"])
    end
  end

  def find_existing_program!(name)
    Program.find_by!(name: name)
  rescue ActiveRecord::RecordNotFound
    raise InvalidProgramError, "Program: #{name} does not exist"
  end

  def collect_errors(type, record, index)
    @row_indexes[record.object_id] ||= index

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
      email: row["Teacher Email"],
      school_id: @school_id
    )
  end

  def find_or_build_classroom(row, teacher)
    key = [ teacher.name, row["Class Name"] ]

    @classrooms[key] ||= Classroom.new(
      school_id: @school_id,
      name: row["Class Name"],
      teacher: teacher
    )
  end
end
