class Admin::GamesController < AdminController
  before_action :set_game, only: %i[ show edit update destroy ]

  def index
    @games = Game.includes(:content_modules).order(:title)
  end

  def show
    @content_modules = @game.content_modules.order(:name)
  end

  def new
    @game = Game.new
  end

  def edit
  end

  def create
    @game = Game.new(game_params)

    if @game.save
      redirect_to [ :admin, @game ], notice: "Game was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @game.update(game_params)
      redirect_to [ :admin, @game ], notice: "Game was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @game.destroy!
    redirect_to admin_games_path, notice: "Game was successfully deleted.", status: :see_other
  end

  private
    def set_game
      @game = Game.find(params.expect(:id))
    end

    def game_params
      params.expect(game: [ :title, :slug, :description ])
    end
end
