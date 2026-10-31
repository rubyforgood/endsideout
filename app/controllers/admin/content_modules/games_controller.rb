class Admin::ContentModules::GamesController < AdminController
  before_action :set_content_module

  def new
    @content = @content_module.contents.build
    load_game_options
  end

  def create
    @content = @content_module.contents.build(contentable: Game.find_by(id: content_params[:contentable_id]))

    if @content.save
      redirect_to edit_admin_content_module_path(@content_module), notice: "Game was successfully added."
    else
      load_game_options
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_content_module
      @content_module = ContentModule.find(params.expect(:content_module_id))
    end

    def load_game_options
      @available_games = @content_module.available_games
      @any_games = Game.exists?
    end

    def content_params
      params.expect(content: [ :contentable_id ])
    end
end
