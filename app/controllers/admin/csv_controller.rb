
require 'csv'

class Admin::CsvController < ApplicationController
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

  def upload

  end
end