class ClassroomProgram < ApplicationRecord
  belongs_to :classroom
  belongs_to :program

  enum :level, { basic: "basic", moderate: "moderate", advanced: "advanced" }, validate: true

  validates :level, presence: true
end
