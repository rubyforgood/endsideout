class InvalidClassroomError < StandardError; end
class InvalidStudentError < StandardError; end

class StudentCsvImporter
  def initialize(csv:, school_id:)
    @csv = csv
    @school_id = school_id
  end


  def import
    puts "Importing students"
    error_messages = {students: {}, classrooms: {}} # key = csv row, value = row data
    students = []
    classrooms = []

    @csv.each_with_index do |row, index|
      next if row.blank?

      #Instantiate but don't persist Classroom record
      #If record is invalid push error message into error messages hash
      #If any classroom records are invalid raise error and return error messages hash to user
      #Loop over classrooms array and save! classroom records if error_messages[:classrooms] is empty 
      classroom = Classroom.new(
        school_id: @school_id,
        name: row['Classroom Name'],
        teacher: row['Teacher'],
      )
      error_messages[:classrooms][index] = classroom.errors.full_messages if classroom.invalid?
      classrooms << classroom

      
      # Classrooms must exist before checking validity of student records 
      student = Student.new(
        first_name: row['Student First Name'],
        last_name: row['Student Last Name'],
        grade_level: row['Grade Level'],
        school_id: @school_id,
      )

      students << student

    end

    if error_messages[:classrooms].empty?
      classrooms.each(&:save!)
    elsif error_messages[:classrooms].any? Raise InvalidClassroomError, error_messages[:classrooms]
    end

    students.each { |student| error_messages[:students][index] = student.errors.full_messages if student.invalid? }
    
    puts "CSV Passed Validations... Creating School Records"
    puts "Are error messages empty?: #{error_messages.empty?}"
    puts "Error Messages: #{error_messages}"
    if error_messages[:students].empty?
      create_school_records
      elsif error_messages[:students].any? Raise InvalidStudentError, error_messages[:students]
    end
  end

  def create_school_records
    #school_id should be passed in from the url params
    #Iterate CSV rows
    @csv.each do |row|
    #Extract and apply teacher column when creating classroom
      classroom = Classroom.find_by!(school_id: school_id, teacher: row['Teacher'], name: row['Classroom Name'])
      puts "Found Classroom: #{classroom.name}"
    #Extract and apply uuid column when creating classroom
    #Extract and apply program column when creating classroom
      classroom.programs.create_or_find_by!(name: row['Program'], level: row['Program Level'])
      puts "Created Program: #{classroom.programs.first.name}"
    #Extract and apply program level column when creating classroom
      classroom.students.create_or_find_by!(first_name: row['Student First Name'], last_name: row['Student Last Name'], grade_level: row['Grade Level'], school_id: @school_id)
      puts "Created Student: #{classroom.students.first.first_name}"
    end
  end
end