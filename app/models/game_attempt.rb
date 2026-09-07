class GameAttempt < ApplicationRecord
  belongs_to :student
  belongs_to :game

  validates :student_id, :game_id, presence: true
  validates :token, presence: true, uniqueness: true

  class << self
    def generate_token(student_id:, game_id:)
      # nonce value ensures that each token is unique for the same params
      Rails.application.message_verifier(:game_attempt).generate({
        student_id: student_id,
        game_id: game_id,
        n: SecureRandom.hex(6)
      })
    end

    def verify_token(token)
      # nonce value is not needed after verifying the token, so we can ignore it
      Rails.application.message_verifier(:game_attempt).verify(token).except("n")
    end
  end

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
