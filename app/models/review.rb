class Review < ActiveRecord::Base
  validates :title, :body, :presence => true
end
