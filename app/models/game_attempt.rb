class GameAttempt < ApplicationRecord
  belongs_to :student
  belongs_to :game

  validates :student_id, :game_id, presence: true
  validates_uniqueness_of :token, allow_nil: true

  class << self
    def generate_token(student_id:, game_id:)
      Rails.application.message_verifier(:game_attempt).generate({
        student_id:,
        game_id:,
        # nonce value ensures that each token is unique, even for the same student
        # and game
        n: SecureRandom.hex(4)
      })
    end

    def verify_token(token)
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
