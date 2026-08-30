class GameAttemptsController < ApplicationController
  before_action :game_attempt_from_token, only: %i[start finish]

  def start
    @game_attempt.start!
    render json: { status: "ok" }
  end

  def finish
    if !@game_attempt.started?
      render json: { status: "error", message: "Game attempt has not been started" }, status: :unprocessable_entity
      return
    end

    if @game_attempt.update(game_attempt_params)
      @game_attempt.finish!
      render json: { status: "ok" }
    end
  end

  private
    def game_attempt_from_token
      @game_attempt = GameAttempt.find_by(token: params[:token])
      return if @game_attempt.present?

      @game_attempt = GameAttempt.create!(create_game_attempt_params)
    end

    def create_game_attempt_params
      game_attempt_attrs = GameAttempt.verify_token(params[:token])
      game_attempt_attrs.merge(token: params[:token])
    end

    # NOTE (@abachman): add params that can be updated by games here
    def game_attempt_params
      params.expect(game_attempt: [ :outcome, :score ])
    end
end
