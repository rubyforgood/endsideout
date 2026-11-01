require "test_helper"

class Admin::ContentModules::GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @content_module = ContentModule.create! name: "Module", program: programs(:one), level: :basic
    sign_in_as users(:one)
  end

  test "new offers only games not yet in the module" do
    @content_module.contents.create! contentable: games(:one)
    expected_games = Game.all - [ games(:one) ]

    get new_admin_content_module_game_url(@content_module)

    assert_response :success
    assert_select "form[action='#{admin_content_module_games_path(@content_module)}']" do
      expected_games.each do |game|
        assert_select "select[name='content[contentable_id]'] option", text: game.title, count: 1
      end
      assert_select "select[name='content[contentable_id]'] option", text: games(:one).title, count: 0
    end
  end

  test "new offers a blank select a game option" do
    get new_admin_content_module_game_url(@content_module)

    assert_select "select[name='content[contentable_id]'] option[value='']", text: "Select a game"
  end

  test "new explains when every game is attached" do
    Game.all.each { |game| @content_module.contents.create! contentable: game }

    get new_admin_content_module_game_url(@content_module)

    assert_response :success
    assert_select "select[name='content[contentable_id]']", count: 0
    assert_select "p", text: /All games are in this module\./
    assert_select "a[href='#{edit_admin_content_module_path(@content_module)}']"
  end

  test "new links to creating a game when no games exist" do
    Game.destroy_all

    get new_admin_content_module_game_url(@content_module)

    assert_response :success
    assert_select "select[name='content[contentable_id]']", count: 0
    assert_select "p", text: /No games yet/
    assert_select "a.link[href='#{new_admin_game_path}']", text: "Create a game"
  end

  test "new requires admin sign in" do
    sign_out

    get new_admin_content_module_game_url(@content_module)

    assert_redirected_to new_admin_session_url
  end

  test "create attaches an existing game to the module" do
    game = games(:one)

    assert_difference -> { @content_module.contents.count }, 1 do
      post admin_content_module_games_url(@content_module), params: { content: { contentable_id: game.id } }
    end

    assert_redirected_to edit_admin_content_module_url(@content_module)
    assert_equal game, @content_module.contents.last.contentable
  end

  test "create does not attach the same game twice" do
    @content_module.contents.create! contentable: games(:one)
    assert_no_difference "Content.count" do
      post admin_content_module_games_url(@content_module), params: { content: { contentable_id: games(:one).id } }
    end

    assert_response :unprocessable_entity
    assert_select "li", text: "Game is already in this module"
  end

  test "create asks for a game when none is selected" do
    assert_no_difference "Content.count" do
      post admin_content_module_games_url(@content_module), params: { content: { contentable_id: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "li", text: "Game must exist"
  end

  test "create asks for a game when the game is unknown" do
    assert_no_difference "Content.count" do
      post admin_content_module_games_url(@content_module), params: { content: { contentable_id: 0 } }
    end

    assert_response :unprocessable_entity
    assert_select "li", text: "Game must exist"
  end

  test "create requires admin sign in" do
    sign_out

    assert_no_difference "Content.count" do
      post admin_content_module_games_url(@content_module), params: { content: { contentable_id: games(:two).id } }
    end
    assert_redirected_to new_admin_session_url
  end
end
