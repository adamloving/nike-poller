class Sample < ActiveRecord::Base
  attr_accessible :start_at, :end_at, :steps, :user

  belongs_to :user
end