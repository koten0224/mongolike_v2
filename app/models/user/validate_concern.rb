class User
  module ValidateConcren
    def self.included(base)
      base.class_eval do
        sub_regex = /[a-z0-9]+(_[a-z0-9]+)*/
        validates :email, format: {with: /\A#{sub_regex}@#{sub_regex}(\.#{sub_regex})+\z/}
        validates :email, length: {in: 8..100}
        validates :password, length: {in: 6..20}
      end
    end
  end
  private_constant :ValidateConcren
end