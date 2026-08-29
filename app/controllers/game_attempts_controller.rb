class GameAttemptsController < ApplicationController
  before_action :set_game_attempt, only: %i[show]
  before_action :game_attempt_from_token, only: %i[start finish]

  def show
    render json: @game_attempt
  end

  def start
    @game_attempt.start!
    render json: { status: "ok" }
  end

  def finish
    if @game_attempt.update(game_attempt_params)
      @game_attempt.finish!
      render json: { status: "ok" }
    end
  end

  private
    def set_game_attempt
      @game_attempt = GameAttempt.find(params[:id])
    end

    def game_attempt_from_token
      @game_attempt = GameAttempt.find_by(token: params[:token])
      return if @game_attempt.present?

      game_attempt_attrs = GameAttempt.verify_token(params[:token])
      @game_attempt = GameAttempt.create!(game_attempt_attrs.merge(token: params[:token]))
    end

    def game_attempt_params
      params.expect(game_attempt: [ :outcome, :score ])
    end
end
