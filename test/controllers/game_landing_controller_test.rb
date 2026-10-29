require "test_helper"

class GameLandingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:one)
    @game = games(:one)
    student_sign_in_as @student
  end

  test "unauthenticated request redirects to student login" do
    student_sign_out
    get play_game_url(@game)
    assert_redirected_to new_student_session_url
  end

  test "show generates a game attempt token and embeds the external game" do
    get play_game_url(@game)
    assert_response :success

    iframe_src = URI(assert_select("iframe").first["src"])
    assert_equal Rails.configuration.x.external_games.host, iframe_src.host
    assert_equal "/games/#{@game.slug}", iframe_src.path

    token = Rack::Utils.parse_nested_query(iframe_src.query)["token"]
    assert_equal(
      { "student_id" => @student.id, "game_id" => @game.id },
      GameAttempt.verify_token(token)
    )
  end
end
