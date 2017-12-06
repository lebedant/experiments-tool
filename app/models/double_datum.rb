class DoubleDatum < ApplicationRecord
  has_many :experiment_datum, as: :target
end
