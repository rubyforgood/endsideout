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

  test "index marks the Games nav link as active" do
    get admin_games_url

    assert_select "nav a.active", text: "Games"
  end

  test "should get new" do
    get new_admin_game_url
    assert_response :success
  end

  test "should create game" do
    assert_difference "Game.count" do
      assert_no_difference "Content.count" do
        post admin_games_url, params: { game: { slug: "new-game", title: "New Game" } }
      end
    end

    assert_redirected_to admin_games_url
  end

  test "index shows how many modules use each game" do
    get admin_games_url

    assert_select "tr:has(a[href='#{admin_game_path(@game)}']) td:nth-child(3)", text: "1"
  end

  test "show lists the modules that use the game" do
    get admin_game_url(@game)

    assert_select "a[href=?]", edit_admin_content_module_path(content_modules(:one)), text: content_modules(:one).name
  end

  test "show says when the game is in no module" do
    get admin_game_url(games(:two))

    assert_select "p", text: "Not in any module yet."
  end

  test "delete confirmation warns when the game is in modules" do
    get admin_game_url(@game)

    assert_select "form[action=?] button[data-turbo-confirm=?]", admin_game_path(@game),
      "Delete this game? It will be removed from 1 module and 1 student attempt will be deleted."
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
