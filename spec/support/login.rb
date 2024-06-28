module LoginSupport 

    def logged_in? 
        if user_signed_in?
            true 
        else
            false 
        end
    end 
end 

RSpec.configure do |config| 
    config.include  LoginSupport 
end 