require "test_helper"

class GameLandingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:ada)
    @game = games(:one)
    student_sign_in_as @student
  end

  test "unauthenticated request redirects to student login" do
    student_sign_out
    get play_game_url(@game)
    assert_redirected_to new_student_session_url
  end

  test "show generates a game attempt token and embeds the game" do
    get play_game_url(@game)
    assert_response :success

    iframe_src = assert_select("iframe").first["src"]
    token = Rack::Utils.parse_nested_query(URI(iframe_src).query)["token"]
    assert_equal(
      { "student_id" => @student.id, "game_id" => @game.id },
      GameAttempt.verify_token(token)
    )
  end

  test "embed renders the quiz mount point" do
    get embed_game_url(@game, token: "some-token")
    assert_response :success
    assert_select "[data-controller='quiz']"
  end
end
