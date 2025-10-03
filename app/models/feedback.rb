class Feedback < ApplicationRecord
    belongs_to :user

    validates :subject, presence: { message: 'を入力してください。' },
                        length: { minimum: 2, maximum: 50, allow_blank: true }
    
    validates :body, presence: { message: 'を入力してください。' },
                     length: { minimum: 2, maximum: 1500, allow_blank: true }
end
