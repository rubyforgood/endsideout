class GameAttempt < ApplicationRecord
  belongs_to :student
  belongs_to :game

  validates :student_id, :game_id, presence: true

  def start!
    update(started_at: Time.current)
  end

  def started?
    started_at.present?
  end

  def finish!(outcome = "completed")
    update(finished_at: Time.current, outcome: outcome)
  end

  def finished?
    finished_at.present?
  end
end
