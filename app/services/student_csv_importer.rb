

class StudentCsvImporter
  class InvalidClassroomError < ActiveRecord::Rollback; end
  class InvalidStudentError < ActiveRecord::Rollback; end
  class InvalidTeacherError < ActiveRecord::Rollback; end

  def initialize(csv:, school_id:)
    @csv = csv
    @school_id = school_id
    @error_messages = { students: {}, classrooms: {}, teachers: {} }
    @students = []
    @classrooms = []
    @teachers = []
  end


  def import
    puts "Importing classrooms, teachers, and students"


    @csv.each_with_index do |row, index|
      next if row.blank?

      classroom = Classroom.new(
        school_id: @school_id,
        name: row['Class Name'],
      )

      @error_messages[:classrooms][index] = classroom.errors.full_messages if classroom.invalid?
      @classrooms << classroom

      
      # Student must be associated with a Classroom before checking validity of Student records
      student = Student.new(
        first_name: row['Student First Name'],
        last_name: row['Student Last Name'],
        grade_level: row['Grade Level'],
        school_id: @school_id,
      )

      student.classroom = classroom

      @students << student

      teacher = Teacher.new(
        name: row['Teacher'],
        school_id: @school_id,
      )

      @error_messages[:teachers][index] = teacher.errors.full_messages if teacher.invalid?
      teacher.classrooms << classroom
      @teachers << teacher
    end

    save_records


  end

  def save_records
    ActiveRecord::Base.transaction do
      if @error_messages[:classrooms].empty?
        @classrooms.each(&:save!)
      else
        raise InvalidClassroomError.new(error_messages[:classrooms])
      end

      if @error_messages[:teachers].empty?
        @teachers.each(&:save!)
      else
        raise InvalidTeacherError, @error_messages[:teachers]
      end

      @students.each_with_index { |student, index| @error_messages[:students][index] = student.errors.full_messages if student.invalid? }

      puts "CSV Passed Validations... Creating School Records"

      if @error_messages[:students].empty?
        create_school_records
      else
        raise InvalidStudentError, error_messages[:students]
      end

    end
  end

  def create_school_records
    #school_id should be passed in from the url params
    #Iterate CSV rows
    @csv.each do |row|
    #Extract and apply teacher column when creating classroom
      teacher = Teacher.find_by!(school_id: @school_id, name: row['Teacher'])

      classroom = Classroom.find_by!(school_id: @school_id, teacher_id: teacher.id, name: row['Class Name'])
      puts "Found Classroom: #{classroom.name}"

      program = Program.create_or_find_by!(name: row['Program'])
      classroom.classroom_programs.create_or_find_by!(program: program, level: row['Program Level'])
      puts "Created Program: #{classroom.programs.first.name}"
    #Extract and apply program level column when creating classroom
      classroom.students.create_or_find_by!(first_name: row['Student First Name'], last_name: row['Student Last Name'], grade_level: row['Grade Level'], school_id: @school_id)
      puts "Created Student: #{classroom.students.first.first_name}"
    end
  end
end