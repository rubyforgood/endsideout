return unless Rails.env.development?

User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.name = "Admin"
  user.password = "password"
end

School.find_or_create_by!(name: "Example School")
