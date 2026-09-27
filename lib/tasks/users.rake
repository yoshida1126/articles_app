namespace :users do
  desc "Attach default profile image to users without one"
  task attach_default_profile: :environment do
    User.find_each do |user|
      next if user.profile_img.attached?

      user.profile_img.attach(
        io: File.open("app/assets/images/profile.jpg"),
        filename: "profile.jpg"
      )
    end
  end
end
