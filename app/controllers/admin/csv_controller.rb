require "csv"

class Admin::CsvController < AdminController
  class CSVHeadersError < StandardError; end
  class StudentBulkImportError < StandardError; end
  class ClassroomBulkImportError < StandardError; end

  IMPORT_ERRORS = [
    CSVHeadersError,
    StudentBulkImportError,
    ClassroomBulkImportError,
    CSV::MalformedCSVError,
    StudentCsvImporter::InvalidClassroomError,
    StudentCsvImporter::InvalidStudentError,
    StudentCsvImporter::InvalidTeacherError
  ].freeze

  CSV_HEADERS = [ "Student First Name", "Student Last Name", "Grade Level", "Class Name", "Teacher", "Teacher Email",
                 "Program", "Program Level" ].freeze

  before_action :set_school

  def download
    csv_data = CSV.generate do |csv|
      csv << CSV_HEADERS
    end

    send_data csv_data,
              filename: "students-#{Date.today}.csv",
              type: "text/csv; charset=utf-8",
              disposition: "attachment"
  end

  def import
    csv_file = params[:file]
    return redirect_to school_students_path(@school), alert: "Choose a CSV file to import." if csv_file.blank?

    csv = CSV.read(csv_file.path, headers: true)
    validate_rows!(csv)
    StudentCsvImporter.new(csv: csv, school_id: @school.id).import

    redirect_to school_students_path(@school), notice: "Students were successfully imported."
  rescue *IMPORT_ERRORS => error
    redirect_to school_students_path(@school), alert: error.message
  end

  private
    def set_school
      @school = School.find(params.expect(:school_id))
    end

    def validate_rows!(csv)
      raise CSVHeadersError, "Headers must match CSV headers" unless CSV_HEADERS == csv.headers

      csv.each do |row|
        raise CSVHeadersError, "Row must have same number of columns as headers" unless CSV_HEADERS.length == row.length

        if @school.students.exists?(first_name: row["Student First Name"], last_name: row["Student Last Name"])
          raise StudentBulkImportError, "Student: #{row["Student First Name"]} #{row["Student Last Name"]} already exists"
        end

        if @school.classrooms.exists?(name: row["Class Name"])
          raise ClassroomBulkImportError, "Classroom: #{row["Class Name"]} already exists"
        end
      end
    end
end
