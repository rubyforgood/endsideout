require "test_helper"

class StudentHomesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # A fresh classroom has no enrollments, so each test builds the ones it needs.
    @classroom = Classroom.create!(name: "Test Classroom", school: schools(:one))
    @student = students(:one)
    @student.update!(classroom: @classroom)
    student_sign_in_as @student
  end

  test "unauthenticated request redirects to student login" do
    student_sign_out
    get student_homes_url
    assert_redirected_to new_student_session_url
  end

  test "shows published module names only" do
    enrollment = enroll(program: programs(:one))
    publish_module(enrollment, name: "Intro")
    publish_module(enrollment, name: "Scheduled", publish_on: 1.day.from_now)

    get student_homes_url
    assert_response :success
    assert_select "summary", text: /Intro/
    assert_select "summary", text: /Scheduled/, count: 0
  end

  test "shows contents in position order" do
    content_module = publish_module(enroll(program: programs(:one))).content_module
    content_module.contents.create!(contentable: games(:one))
    link_content = content_module.contents.create!(contentable: links(:one))

    get student_homes_url
    assert_equal [ games(:one).title, links(:one).title ], listed_titles

    link_content.move(:up)

    get student_homes_url
    assert_equal [ links(:one).title, games(:one).title ], listed_titles
  end

  test "most recently published module has the open attribute" do
    enrollment = enroll(program: programs(:one))
    publish_module(enrollment, name: "Older Module", publish_on: 1.week.ago.to_date)
    publish_module(enrollment, name: "Newer Module", publish_on: Date.current)

    get student_homes_url
    assert_select "details[open]", count: 1
    assert_select "details[open] summary", text: /Newer Module/
  end

  test "all modules published on the same latest date have the open attribute" do
    enrollment = enroll(program: programs(:one))
    publish_module(enrollment, name: "First Module", publish_on: Date.current)
    publish_module(enrollment, name: "Second Module", publish_on: Date.current)

    get student_homes_url
    assert_select "details[open]", count: 2
  end

  test "shows empty state when no modules are published" do
    enrollment = enroll(program: programs(:one))
    publish_module(enrollment, publish_on: nil)

    get student_homes_url
    assert_select "p", text: /No modules published yet/
  end

  test "does not show tab bar for single program enrollment" do
    enroll(program: programs(:one))

    get student_homes_url
    assert_select "[role='tablist']", count: 0
  end

  test "shows tab bar when classroom has multiple program enrollments" do
    enroll(program: programs(:one))
    enroll(program: programs(:two))

    get student_homes_url
    assert_select "[role='tablist']"
    assert_select "a[role='tab']", minimum: 2
  end

  test "tab switching shows the selected program as active" do
    enroll(program: programs(:one))
    second_enrollment = enroll(program: programs(:two))

    get student_homes_url(classroom_program_id: second_enrollment.id)
    assert_select "a[role='tab'][aria-selected='true'][href*='classroom_program_id=#{second_enrollment.id}']"
  end

  private

  def enroll(program:, level: "basic")
    @classroom.classroom_programs.create!(program: program, level: level)
  end

  # Creates a module in the enrollment's program and level, and schedules it for the classroom.
  def publish_module(enrollment, name: "Module", publish_on: Date.current)
    content_module = ContentModule.create!(program: enrollment.program, level: enrollment.level, name: name)
    enrollment.classroom_modules.create!(content_module: content_module, publish_on: publish_on)
  end

  # The " ↗" suffix marks external links, so strip it to compare plain titles.
  def listed_titles
    css_select("details li a").map { |a| a.text.delete_suffix(" ↗") }
  end
end
