class DoubleDatum < ApplicationRecord
  has_many :test_data, as: :target
end
