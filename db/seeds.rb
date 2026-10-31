def maybe(&block)
  return unless Faker::Boolean.boolean

  block.call
end

programs = [
  Program.find_or_create_by!(name: "Know Your Health"),
  Program.find_or_create_by!(name: "3D Wellness")
]
User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.name = "Admin"
  user.password = "password"
end

# Production should not have any seeded data for the content or schools
return if Rails.env.production?

fruit_veggie_quiz = Game.find_or_create_by!(slug: "fruit-veggie-quiz") do |game|
  game.title = "Fruit and Veggie Quiz"
  game.description = "Sort fruits and vegetables into the right food groups."
end
sleep_habits = Game.find_or_create_by!(slug: "sleep-habits") do |game|
  game.title = "Sleep Habits"
  game.description = "Pick the habits that help you get a good night's sleep."
end
# Intentionally not attached to any module so the "Add game" dropdown has an option.
Game.find_or_create_by!(slug: "hydration-heroes") do |game|
  game.title = "Hydration Heroes"
  game.description = "Learn how much water your body needs each day."
end
games_by_program = { programs.first => fruit_veggie_quiz, programs.last => sleep_habits }

# The first module of each program and level has a survey then a game.
# The second module of the basic level has a game then a survey.
# Other modules have only a survey.
ContentModule.levels.keys.each do |level|
  programs.each do |program|
    game = games_by_program.fetch(program)
    2.times do |i|
      mod = program.content_modules.create!(name: "#{program.name} #{level.humanize} Module #{i + 1}", level: level)
      link = Link.new(title: "Survey #{i + 1}", url: "https://example.com/survey/#{program.id}-#{level}-#{i}", link_type: "survey")
      contentables = if i.zero?
        [ link, game ]
      elsif level == "basic"
        [ game, link ]
      else
        [ link ]
      end
      contentables.each { |contentable| mod.contents.create!(contentable: contentable) }
    end
  end
end



school = School.find_or_create_by!(name: "Example School")

teachers = 3.times.map do
  school.teachers.create!(
    name: Faker::Name.name,
    email: maybe { Faker::Internet.email(domain: "example.com") }
  )
end

def build_student_attrs(overrides = {})
  {
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: maybe { Faker::Internet.email(domain: 'example.com') },
    gender: maybe { Student.genders.keys.sample }
  }.merge(overrides)
end

# randomly sample 3 grade levels and create 10 students for each grade level
grades = (1..12).to_a.sample(3)
grades.each do |grade|
  classrooms = 2.times.map do |i|
    classroom = school.classrooms.create!(
      name: "Classroom #{i + 1}",
      teacher: maybe { teachers.sample },
      uuid: SecureRandom.urlsafe_base64(32)
    )
    assigned = Faker::Boolean.boolean ? [ programs.sample ] : programs
    assigned.each do |program|
      classroom_program = classroom.classroom_programs.create!(program: program, level: %w[basic moderate advanced].sample)
      classroom_program.generate_modules!
    end
    classroom
  end
  students = 10.times.map { |i| build_student_attrs(grade_level: grade, classroom_id: classrooms[i % 2].id) }
  school.students.create!(students)
end
