require "test_helper"

class Admin::SchoolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school = schools(:one)
    sign_in_as users(:one)
  end

  test "should get index" do
    get admin_schools_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_school_url
    assert_response :success
  end

  test "should create school" do
    assert_difference("School.count") do
      post admin_schools_url, params: { school: { name: @school.name } }
    end

    assert_redirected_to admin_school_url(School.last)
  end

  test "should show school" do
    get admin_school_url(@school)
    assert_response :success
  end

  test "show renders lazy turbo frames for students, classrooms, and teachers tabs" do
    get admin_school_url(@school)
    assert_response :success

    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(@school, :students)}[loading=lazy][src=?]", admin_school_students_path(@school)
    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(@school, :classrooms)}[loading=lazy][src=?]", admin_school_classrooms_path(@school)
    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(@school, :teachers)}[loading=lazy][src=?]", admin_school_teachers_path(@school)
  end

  test "show defaults to the students tab when no tab param is given" do
    get admin_school_url(@school)

    assert_select "[role=tab][aria-selected=true]", text: "Students"
  end

  test "show activates the tab named in the tab param" do
    get admin_school_url(@school, tab: "teachers")

    assert_select "[role=tab][aria-selected=true]", text: "Teachers"
  end

  test "should get edit" do
    get edit_admin_school_url(@school)
    assert_response :success
  end

  test "should update school" do
    patch admin_school_url(@school), params: { school: { name: @school.name } }
    assert_redirected_to admin_school_url(@school)
  end

  test "should destroy school" do
    assert_difference("School.count", -1) do
      delete admin_school_url(@school)
    end

    assert_redirected_to admin_schools_url
  end
end
