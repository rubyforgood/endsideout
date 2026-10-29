class GameLandingController < ApplicationController
  include StudentAuthentication

  def show
    @game = Game.find(params[:id])
    @game_attempt_token = GameAttempt.generate_token(student_id: current_student.id, game_id: @game.id)
  end

  private

  def current_student = Current.student
end
