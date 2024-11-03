# Admin User
User.find_or_create_by!(email_address: "edu@plum.com.ar") do |user|
  user.password = "123456"
  user.first_name = "Eduardo"
  user.last_name = "Depetris"
  user.role = "administrator"
end

# Regular User
[
  "Gaston Coria", "Alejandro Barrios", "Alvaro Cuesta", "Martin Hernandez", "Sabrina Cuevas", "Yanina Celi", "Mauro Marozzi",
  "Fernando Perez", "Mariano Perez", "Franco Altamirano", "Federico Saenz", "Franco Colapinto", "Gaston Mazzacane", "Esteban Guerrieri",
  "Jose Lopez", "Agustin Canapino", "Matias Rossi", "Facundo Ardusso", "Leonel Pernia", "Nestor Girolami", "Bernardo Llaver",
  "Carlos Sainz", "Fernando Alonso", "Sebastian Vettel", "Lewis Hamilton", "Max Verstappen", "Valtteri Bottas", "Daniel Ricciardo",
  "Leonel Messi", "Cristiano Ronaldo", "Kylian Mbappe", "Mohamed Salah", "Sadio Mane", "Kevin De Bruyne", "Robert Lewandowski"
].each do |name|
  first_name, last_name = name.split(" ")
  email = "#{first_name[0].downcase}#{last_name.downcase}@plum.com.ar"
  User.find_or_create_by!(email_address: email) do |user|
    user.first_name = first_name
    user.last_name = last_name
    user.password = "123456"
    user.role = "member"
  end
end

# Inactive Users
User.last(3).each do |user|
  user.update!(inactive_at: Time.current)
end
