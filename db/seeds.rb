# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'dotenv'
Dotenv.load

admin_user = User.find_or_create_by!(email: ENV['ADMIN_MAIL']) do |user|
  user.admin = true,
  user.name = 'Admin User',
  user.password = ENV['ADMIN_PASS'],
  user.password_confirmation = ENV['ADMIN_PASS'],
  user.confirmed_at = Time.zone.now
end
admin_user.profile_img.attach(io: File.open('app/assets/images/admin-profile.png'),
                        filename: 'admin-profile.png')

user = User.find_or_create_by!(email: 'example@example.org') do |user|
  user.name = 'Example User',
  user.password = 'foobar',
  user.password_confirmation = 'foobar',
  user.confirmed_at = Time.zone.now
end
user.profile_img.attach(io: File.open('app/assets/images/profile.jpg'),
                        filename: 'profile.jpg')

20.times do |n|
  name = Faker::Name.name
  email = "example-#{n + 1}@example.org"
  password = 'password'
  user = User.find_or_create_by!(email: email) do |user|
    user.name = name,
    user.introduction = Faker::Lorem.sentence(word_count: 2),
    user.password = password,
    user.password_confirmation = password,
    user.confirmed_at = Time.zone.now
  end
end

users = User.order(:created_at).take(6)
array = %w[テスト テスト記事 記事]

array.each do |tag|
  5.times do
    title = 'test'
    content = Faker::Lorem.sentence(word_count: 5)

    users.each do |user|
      article = user.articles.find_or_initialize_by(title: title)

      if article.new_record?
        article.content = content
        article.tag_list = tag
        article.draft = false
        article.save!
      else
        unless article.tag_list.include?(tag)
          article.tag_list.add(tag)
          article.draft = false
          article.save!
        end
      end
    end
  end
end

Article.where(draft: true, title: 'test').update_all(draft: false)

users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]

following.each do |followed|
  user.follow(followed) unless user.following?(followed)
end

followers.each do |follower|
  follower.follow(user) unless follower.following?(user)
end
