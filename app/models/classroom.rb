class Classroom < ApplicationRecord
  belongs_to :school
  has_many :students
  has_and_belongs_to_many :programs
end
