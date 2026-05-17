class Program < ApplicationRecord
  has_many :classroom_programs, dependent: :destroy
  has_many :classrooms, through: :classroom_programs
end
