class Setting < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :parent, polymorphic: true
end
