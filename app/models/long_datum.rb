class LongDatum < ApplicationRecord
  has_many :experiment_data, class_name: 'Experiment::Datum', as: :target
end
