# Admin User
User.find_or_create_by!(email_address: "edu@plum.com.ar") do |user|
  user.password = "123456"
  user.first_name = "Eduardo"
  user.last_name = "Depetris"
  user.role = "administrator"
end

60.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  email = "#{first_name[0].downcase}#{last_name.downcase}@plum.com.ar"

  User.find_or_create_by!(email_address: email) do |user|
    user.first_name = first_name
    user.last_name  = last_name
    user.password   = "123456"
    user.role       = "member"
  end
end

# Inactive Users
User.last(3).each do |user|
  user.update!(disabled_at: Time.current)
end

50.times do
  name = Faker::Company.unique.name
  Client.find_or_create_by!(name: name) do |client|
    client.email = Faker::Internet.unique.email(name: name, domain: "plum.com.ar")
    client.note = "The client wants the report to be delivered on the #{Faker::Date.forward(days: 30).strftime('%A, %B %d')}."
  end
end
