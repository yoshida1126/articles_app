class Feedback < ApplicationRecord
    belongs_to :user

    validates :subject, presence: true,
                        length: { minimum: 2, maximum: 50, allow_blank: true }
    
    validates :body, presence: true,
                     length: { minimum: 2, maximum: 1500, allow_blank: true }
end
