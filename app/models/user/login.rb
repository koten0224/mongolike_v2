class User
  class Login
    attr_accessor :email, :password, :user
    include ActiveModel::Model
    include ValidateConcern
    validate :authenticate

    def authenticate
      user = User.find_by(email: @email)&.authenticate @password
      unless user
        errors[:user] << 'email or password invalid.'
      else
        @user = user
      end
    end
  end
end