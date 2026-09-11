require "application_system_test_case"

class CsvImportTest < ApplicationSystemTestCase
  setup do
    @school = schools(:one)
    sign_in_as_admin
  end

  test "admin imports students from a CSV" do
    visit school_students_path(@school)

    assert_no_selector ".modal-box", text: "Import students"

    click_on "Import CSV"

    assert_selector ".modal-box", text: "Import students"
    assert_link "Download the CSV template", href: school_csv_template_path(@school)

    attach_file "file", file_fixture("students.csv")
    click_on "Import"

    assert_selector ".alert-success", text: "Students were successfully imported."
    assert_selector "#students td", text: "Turing"
    assert_selector "#students td", text: "Jemison"
  end

  test "admin sees why a CSV was rejected" do
    visit school_students_path(@school)
    click_on "Import CSV"

    attach_file "file", file_fixture("students_existing_student.csv")
    click_on "Import"

    assert_selector ".alert-error", text: "Student: Ada Lovelace already exists"
  end

  test "admin can close the dialog without importing" do
    visit school_students_path(@school)
    click_on "Import CSV"

    assert_selector ".modal-box", text: "Import students"

    click_on "Cancel"

    assert_no_selector ".modal-box", text: "Import students"
  end

  private
    def sign_in_as_admin
      visit new_session_path
      fill_in "email_address", with: users(:admin).email_address
      fill_in "password", with: "password"
      click_on "Sign in"

      # Wait for the redirect to land so the session cookie is set before the
      # next visit.
      assert_selector "h1", text: "Schools"
    end
end
