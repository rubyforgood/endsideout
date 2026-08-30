
require 'csv'

class CSVHeadersError < StandardError; end
class StudentBulkImportError < StandardError; end
class ClassroomBulkImportError < StandardError; end

class Admin::CsvController < ApplicationController
  skip_forgery_protection only: :import
  CSV_HEADERS = ["Student First Name", "Student Last Name", "Grade Level", "Class Name", "Teacher", "Program", "Program Level"].freeze

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
    if csv_file.present?
      csv = CSV.read(csv_file.path, headers: true)
      #check if headers are equal to CSV_HEADERS and return with Headers must match CSV headers error if not
      raise CSVHeadersError, "Headers must match CSV headers" unless CSV_HEADERS == csv.headers

      #iterate through each row and validate that each row has the same number of columns as the headers
      #if not, return with Row must have same number of columns as headers error
      puts "Checking CSV Header validity"
      csv.each do |row|
        raise CSVHeadersError, "Row must have same number of columns as headers" unless CSV_HEADERS.length == row.length
        raise StudentBulkImportError, "Student already exists" if Student.find_by(first_name: row["Student First Name"], last_name: row["Student Last Name"])
        raise ClassroomBulkImportError, "Classroom: #{row["Class Name"]} already exists" if Classroom.find_by(name: row["Class Name"])
      end
      # pass file to importer
      StudentCsvImporter.new(csv: csv, school_id: 1).import
    end
  end
end