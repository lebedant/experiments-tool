class DoubleDatum < ApplicationRecord
  has_many :experiment_datum, class_name: 'Experiment::Datum', as: :target
end
