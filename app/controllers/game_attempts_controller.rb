class GameAttemptsController < ApplicationController
  before_action :set_game_attempt, only: %i[show update]

  def show
    render json: @game_attempt
  end

  def create
  end

  def update
  end

  private
    def set_game_attempt
      @game_attempt = GameAttempt.find(params.expect(:id))
    end

    def game_attempt_params
      params.expect(game_attempt: [ :student_id, :game_id, :outcome, :score ])
    end
end
