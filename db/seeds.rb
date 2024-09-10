# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user = User.create!(name: "Example User",
             email: "example@example.org",
             password: "foobar",
             password_confirmation: "foobar",
             confirmed_at: Time.zone.now) 
user.profile_img.attach(io: File.open("app/assets/images/profile.jpg"),
                        filename: "profile.jpg")

99.times do |n| 
    name = Faker::Name.name 
    email = "example-#{n+1}@example.org"
    password = "password"
    user = User.create!(name: name,
                 email: email,
                 password: password,
                 password_confirmation: password,
                 confirmed_at: Time.zone.now) 
    user.profile_img.attach(io: File.open("app/assets/images/profile.jpg"),
                            filename: "profile.jpg")
end 

users = User.order(:created_at).take(6) 
array = %w(テスト テスト記事 記事)
array.each { |tag|
  5.times do 
    title = "test"
    tag_list = ActsAsTaggableOn::Tag.new 
    tag_list.name = tag
    tag_list.save  
    content = Faker::Lorem.sentence(word_count: 5) 
    users.each { |user| user.articles.create!(title: title, tag_list: tag_list, content: content)}
  end 
}


users = User.all 
user = users.first 
following = users[2..50] 
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }