class GameLandingController < ApplicationController
  include StudentAuthentication

  layout "embed", only: :embed

  def show
    @game = Game.find(params[:id])
    @game_attempt_token = GameAttempt.generate_token(student_id: current_student.id, game_id: @game.id)

    logger.info("game attempt token: #{{ game_attempt_token: @game_attempt_token, student_id: current_student.id, game_id: @game.id }}")
  end

  def embed
    @game = Game.find(params[:id])
  end

  private

  def current_student = Current.student
  helper_method :current_student
end
