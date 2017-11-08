class LongDatum < ApplicationRecord
  has_many :test_datum, as: :target
end
