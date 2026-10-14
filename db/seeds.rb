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

ContentModule.levels.keys.each do |level|
  programs.each do |program|
    2.times do |i|
      mod = program.content_modules.create!(name: "#{program.name} #{level.humanize} Module #{i + 1}", level: level, position: i + 1)
      # TODO: Update this when the delegated types migration is completed
      link = Link.new(title: "Survey #{i + 1}", url: "https://example.com/survey/#{program.id}-#{level}-#{i}", link_type: "survey", position: 1, content_module: mod)
      mod.contents.create! contentable: link
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
