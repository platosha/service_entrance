# encoding: utf-8

# Generated with RailsBricks
# Initial seed file to use with Devise User Model

# Temporary admin account
u = User.new(
    username: "admin",
    email: "admin@example.com",
    password: "1234",
    password_confirmation: "1234",
    admin: true
)
u.skip_confirmation!
u.save!

# Populate db with image exhibits
Dir.glob(File.join(File.dirname(__FILE__), 'seeds', 'images', '*')).each do |image_path|
  e =  Exhibit.new(
    subtype: 'object',
    name: 'Untiled',
    author: 'Name',
    year: 2014,
    materials: 'Marble, stone, acrylic, oil',
    size: '150 × 150 cm',
    owner: 'Courtesy'
  )
  e.image = File.open(image_path)
  e.save!
end

5.times do
  Note.new(
    body: 'Эротическое аккумулирует художественный талант.',
    author: 'Антон Бекасов'
  ).save!
  Note.new(
    body: 'Миракль, в том числе, использует резкий драматизм.',
    author: 'Яндекс Весна'
  ).save!
  Note.new(
    body: 'Шиллер утверждал: иносказательность образа имитирует комплекс агрессивности.',
    author: 'Яндекс Весна'
  ).save!
end
