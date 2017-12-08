class User < ActiveRecord::Base
  has_many :tweets

  has_secure_password

  def slug
    self.username.downcase.split(" ").join("-")
  end

  def self.find_by_slug(slug)
    match = ""

    self.all.each do |user|
      if user.slug == slug
         match = user
      end
    end
    match
  end
end
