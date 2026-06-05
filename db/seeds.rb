# Admin User
admin = User.find_or_create_by!(email_address: "edu@plum.com.ar") do |user|
  user.password = "123456"
  user.first_name = "Eduardo"
  user.last_name = "Depetris"
  user.role = "administrator"
end

# Users
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

User.last(3).each do |user|
  user.update!(disabled_at: Time.current)
end

# Clients
50.times do
  name = Faker::Company.unique.name
  Client.find_or_create_by!(name: name) do |client|
    client.email = Faker::Internet.unique.email(name: name, domain: "plum.com.ar")
    client.note = "The client wants the report to be delivered on the #{Faker::Date.forward(days: 30).strftime('%A, %B %d')}."
  end
end

Client.last(5).each do |client|
  client.update!(disabled_at: Time.current)
end

# Projects
50.times do
  Project.find_or_create_by!(name: Faker::App.unique.name)
end

Project.all.each_with_index do |project, index|
  next if index.even?
  project.update!(client: Client.all.sample)
end

Project.where(client: nil).limit(5).update_all(client_id: Client.all.sample.id)

Project.last(5).each do |project|
  project.update!(disabled_at: Time.current)
end

# Project Assignments
Project.all.limit(45).each do |project|
  project.users << User.excluding(project.users).all.sample(rand(1..8))
  project.save!
  project.project_assignments.sample.update!(role: "manager")
end

# Time Entries
Project.active.all.each do |project|
  project.users.each do |user|
    (3.months.ago.to_date..Date.today).each do |date|
      next if date.on_weekend?
      [ 120, 180, 180 ].each do |duration|
        TimeEntry.find_or_create_by(user: user, project: project, date: date) do |time_entry|
          time_entry.duration_minutes = duration
          time_entry.description = Faker::Lorem.sentence(word_count: rand(4..14))
        end
      end
    end
  end
end

User.all.sample(10).each do |user|
  TimeEntry.create!(
    user: user,
    duration_minutes: rand(120..240),
    description: Faker::Lorem.sentence(word_count: rand(4..14)),
    date: Faker::Date.between(from: 3.months.ago, to: Date.today)
  )
end

# Ai::Chats
# Run this to load all models from RubyLLM's bundled catalog
# Rake::Task["ruby_llm:load_models"].invoke

# Local Ollama models aren't in RubyLLM's bundled catalog, so register the
# default model explicitly.
ai_model = Ai::Model.find_or_create_by!(model_id: RubyLLM.config.default_model, provider: "ollama") do |model|
  model.name = RubyLLM.config.default_model
  model.family = "ollama"
  model.modalities = { input: %w[text], output: %w[text] }
  model.capabilities = %w[streaming function_calling structured_output]
end

25.times do
  updated_at = Faker::Date.between(from: 3.months.ago, to: Date.today)
  title = Faker::Lorem.sentence(word_count: rand(3..6))

  chat = admin.ai_chats.create!(model: ai_model, title: title, created_at: updated_at, updated_at: updated_at)
  chat.ai_messages.create!(role: "user",      content: "Hours per client this month?", ai_model: ai_model)
  chat.ai_messages.create!(role: "assistant", content: "Acme: 42.5h\nGlobex: 18.0h",   ai_model: ai_model)
end
