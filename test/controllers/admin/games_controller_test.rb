require "test_helper"

class Admin::GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
    sign_in_as users(:one)
  end

  test "should get index" do
    get admin_games_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_game_url
    assert_response :success
  end

  test "creating a game does not add it to a module" do
    assert_difference "Game.count" do
      assert_no_difference "Content.count" do
        post admin_games_url, params: { game: { slug: "new-game", title: "New Game" } }
      end
    end

    assert_redirected_to admin_games_url
  end

  test "should get edit" do
    get edit_admin_game_url(@game)
    assert_response :success
  end

  test "should update game" do
    patch admin_game_url(@game), params: { game: { slug: "updated-game", title: "Updated Game" } }
    assert_redirected_to admin_game_url(@game)
  end

  test "should destroy game" do
    assert_difference("Game.count", -1) do
      delete admin_game_url(@game)
    end

    assert_redirected_to admin_games_url
  end
end
